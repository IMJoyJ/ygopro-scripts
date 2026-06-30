--黒き竜のエクレシア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续，以及①的暂时除外并特召、②的洗回卡组的两个效果
function s.initial_effect(c)
	-- 在卡片信息中记录该卡记述了卡名「阿不思的落胤」（卡号 68468459）
	aux.AddCodeList(c,68468459)
	-- 注册同调召唤的手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 触发条件判定：当前必须是自己或对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤条件：选择卡名为「阿不思的落胤」或记述该卡名，等级在4星以下，且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	-- 检查卡片是否是「阿不思的落胤」或记述该卡名的4星以下可特殊召唤怪兽
	return aux.IsCodeOrListed(c,68468459) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查：检查自己场上的怪兽区域空间，自身是否能被除外，以及卡组或墓地是否存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身离场后是否能留出可用的主要怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		and c:IsAbleToRemove()
		-- 检查自己的卡组或墓地是否存在符合特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：将自身卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置当前连锁的操作信息：从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理的操作：使自身暂时除外并注册回合结束时返回场上的效果，并在自己场上特殊召唤1只卡组或墓地的符合条件怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 判断自身是否存在于该连锁中，并将其暂时除外
	if c:IsRelateToChain() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"直到结束阶段除外"
			-- 这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 将结束阶段返回场上的延迟效果注册到全局环境中
			Duel.RegisterEffect(e1,tp)
		end
		-- 检查自己场上是否有可用的主要怪兽区
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己的卡组或墓地选择1张符合条件的怪兽（受王之谷影响）
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 以表侧表示特殊召唤选择的怪兽
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 返回场上效果的条件判定：检查被除外的卡是否还在除外状态且没有变动
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 返回场上效果的具体操作：将暂时除外的卡片返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被除外的自身返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 过滤条件：选择自己墓地·除外状态下的8星融合怪兽，且场上存在可返回卡组的卡
function s.tdfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevel(8) and c:IsType(TYPE_FUSION)
		-- 检查场上是否存在可以送回卡组的卡片
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果发动的目标检查与选择：选择墓地·除外状态下的1只8星融合怪兽和场上1张卡作为对象，并将自身也加入，准备全部洗回卡组
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查墓地或除外中是否有符合条件的8星融合怪兽，且自身也可以送回卡组
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) and c:IsAbleToDeck() end
	-- 提示选择第一张需要返回卡组的卡（即8星融合怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择墓地或除外中的1只8星融合怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	-- 提示选择第二张需要返回卡组的卡（即场上的卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择场上的1张卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	g1:AddCard(c)
	-- 设置当前连锁的操作信息：将这3张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
end
-- 效果处理的操作：将作为对象的2张卡以及自身（共3张卡）送回持有者卡组并洗牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 获取在连锁处理时依然符合对象关系的卡片组
	local g=Duel.GetTargetsRelateToChain()
	g:AddCard(c)
	-- 检查这3张卡（2个对象卡加自身）是否依然都可以洗回卡组，如果不足3张则不处理
	if g:FilterCount(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)~=3 then return end
	-- 将这3张卡全部送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
