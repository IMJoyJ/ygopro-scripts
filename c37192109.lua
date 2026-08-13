--PSYフレームロード・Ζ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，以这张卡以外的自己墓地1张「PSY骨架」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 定义卡的初始化函数：添加同调召唤手续（调整+调整以外怪兽1只以上）并启用苏生限制；注册①效果（诱发即时效果，对方回合可发动，取对象除外）和②效果（墓地起动，回额外并回收PSY骨架卡）。
function c37192109.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果原文：“①：1回合1次，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。这个效果在对方回合也能发动。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37192109,0))  --"对方怪兽和这张卡除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37192109.rmtg)
	e1:SetOperation(c37192109.rmop)
	c:RegisterEffect(e1)
	-- 对应②效果原文：“②：这张卡在墓地存在的场合，以这张卡以外的自己墓地1张「PSY骨架」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37192109,1))  --"「PSY骨架」卡回到手卡"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c37192109.thtg)
	e2:SetOperation(c37192109.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象过滤条件：对方场上的表侧攻击表示怪兽、是特殊召唤、且可以除外。
function c37192109.rmfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToRemove()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 定义①效果的发动条件和取对象目标判定：若指定了对象则检查其是否符合条件；发动时检查本卡可除外且对方场上存在符合条件的对象怪兽。
function c37192109.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37192109.rmfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 继续发动条件判定：确认对方场上存在至少1只满足rmfilter且可作为效果对象的特殊召唤表侧攻击表示怪兽。
		and Duel.IsExistingTarget(c37192109.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要除外的卡”的提示，引导玩家选择①效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足条件的特殊召唤表侧攻击表示怪兽作为效果对象，并与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c37192109.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息：本次为除外效果，预计除外的卡数为2张（对象怪兽和这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 定义①效果处理：确认双方仍关联后，将自身和对象怪兽以暂时除外方式除外；为除外的卡登记返回标记并注册持续效果，使它们在下次自己准备阶段返回场上；同时处理在准备阶段发动时的重置计数。
function c37192109.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将自身和对象怪兽以效果原因暂时除外；若成功执行则继续后续处理。
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		local rct=1
		-- 如果当前正在自己的准备阶段发动，则返回效果需要跨越到下一次自己的准备阶段，因此重置次数设为2；否则设为1。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then rct=2 end
		-- 获取刚才被实际除外的卡片组，用于对这些卡统一登记返回标记。
		local og=Duel.GetOperatedGroup()
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,rct,fid)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 对应①效果中“那只怪兽和场上的这张卡直到下次的自己准备阶段除外”的返回处理，以及②效果中“这张卡回到额外卡组，作为对象的卡加入手卡”的处理。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(c37192109.retcon)
		e1:SetOperation(c37192109.retop)
		-- 判断当前是否为本效果发动者的准备阶段，用于确定返回时点与重置计数。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 把当前回合数存入效果值，作为基准，防止在发动当回合的准备阶段立即触发返回。
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 将这个持续效果注册到场上，使它在自己的准备阶段触发，从而把暂时除外的卡返回。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义返回卡过滤函数：检查卡上登记的flag标记是否等于本次除外的fid，以确定哪些卡需要返回。
function c37192109.retfilter(c,fid)
	return c:GetFlagEffectLabel(37192109)==fid
end
-- 定义返回效果的触发条件：在自己的准备阶段且已经过一次准备阶段，并且记录组中仍有带对应标记的卡；若没有则清理记录并重置效果。
function c37192109.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前不是自己的准备阶段，或仍处于发动当次的准备阶段（回合数未变），则不触发返回。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c37192109.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义返回效果处理：从记录组中筛选出带对应标记的卡，将它们依次返回场上。
function c37192109.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c37192109.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		-- 将暂时除外的卡返回场上，按照离场前的表示形式放置。
		Duel.ReturnToField(tc)
		tc=sg:GetNext()
	end
end
-- 定义②效果的对象过滤条件：自己墓地中的「PSY骨架」卡，且可以加入手卡。
function c37192109.thfilter(c)
	return c:IsSetCard(0xc1) and c:IsAbleToHand()
end
-- 定义②效果的发动条件和取对象判定：自身在墓地且可回额外卡组，且自己墓地存在除自身以外的满足条件的「PSY骨架」卡。
function c37192109.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37192109.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 确认自己墓地存在至少1张符合条件的「PSY骨架」卡可以作为②效果的对象（不包含自身）。
		and Duel.IsExistingTarget(c37192109.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示“请选择要加入手牌的卡”的提示，引导玩家选择②效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的「PSY骨架」卡作为②效果的对象，并与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c37192109.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息：将对象卡加入手牌，数量1张，供其他效果参照。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将这张卡自身返回额外卡组，数量1张。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 定义②效果处理：若这张卡仍与效果关联，将其洗回额外卡组；成功回额外后，若对象仍关联，则将对象加入手牌。
function c37192109.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，若关联则将其洗回额外卡组，并确认返回成功。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 将②效果的对象卡加入持有者手牌（以效果原因）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
