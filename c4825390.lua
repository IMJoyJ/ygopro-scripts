--イチロクの魔物台帳
-- 效果：
-- ①：以对方场上最多2只怪兽为对象才能发动。那些怪兽直到结束阶段除外。那之后，对方回复这个效果从场上离开的怪兽数量×1000基本分。
local s,id,o=GetID()
-- 创建并注册该卡的①效果：设置效果描述、类别为除外与回复、取对象属性、发动类型为魔法卡发动、自由时点、提示时点，指定目标选择函数与效果处理函数。
function s.initial_effect(c)
	-- ①：以对方场上最多2只怪兽为对象才能发动。那些怪兽直到结束阶段除外。那之后，对方回复这个效果从场上离开的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 发动时的目标选择处理：确认存在可除外的对方怪兽后，提示玩家选择对方场上1-2只可除外的怪兽作为对象，并设置除外相关的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动条件检查：确认对方怪兽区是否存在至少1只能够被除外的怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方怪兽区选择1-2只可除外的怪兽作为效果对象，并将它们记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,2,nil)
	-- 设置操作信息：声明本连锁将执行除外操作，对象为已选卡组g，数量为#g，供后续时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果处理阶段：获取并过滤仍与本效果相关的对象，将其暂时除外；为这些怪兽登记结束阶段返回的标记，并注册结束阶段返回场上的效果；随后让对方回复除外数量×1000的LP。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得发动时选择的对象组，并过滤出仍与该效果有关联的卡（即仍能被本效果处理的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将过滤后的对象怪兽以效果原因暂时除外；若实际除外成功（数量不为0），才继续执行后续的返回和回复处理。
	if Duel.Remove(tg,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 获取上次除外操作实际除外的卡片组，用于确定结束阶段应返回的怪兽数量以及回复LP数值。
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 那些怪兽直到结束阶段除外。那之后，对方回复这个效果从场上离开的怪兽数量×1000基本分。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.retop)
		-- 将结束阶段返回场上的效果注册到当前玩家，使该效果在结束阶段时触发。
		Duel.RegisterEffect(e1,tp)
		-- 中断当前效果处理，使后续的LP回复与之前的除外不再视为同一时点处理，符合效果原文“那之后”的先后顺序。
		Duel.BreakEffect()
		-- 让对方（1-tp）回复LP，回复数值为实际被除外的怪兽数量#og乘以1000，回复原因为效果。
		Duel.Recover(1-tp,#og*1000,REASON_EFFECT)
	end
end
-- 过滤函数：判断一张卡是否带有本效果设置的标记，即是否曾被本效果暂时除外。
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 结束阶段返回处理：从标记组中筛选仍带有标记的怪兽；若对方怪兽区可用格子充足则全部返回，若不足则让玩家选择其中1只返回。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	-- 判断条件：若需要返回的怪兽数量大于1，且对方怪兽区可用格子只有1个，则只能选择1只返回，避免因格子不足导致处理异常。
	if sg:GetCount()>1 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)==1 then
		-- 在需要选择返回怪兽时，显示提示让当前玩家选择要回到场上的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要回到场上的怪兽"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 将选中的怪兽返回对方场上（恢复离场前的表示形式）。
		Duel.ReturnToField(tc)
	else
		local tc=sg:GetFirst()
		while tc do
			-- 将标记怪兽逐一返回对方场上（恢复离场前的表示形式）。
			Duel.ReturnToField(tc)
			tc=sg:GetNext()
		end
	end
end
