--リターンソウル
-- 效果：
-- 结束阶段时才能发动。可以使这个回合被破坏的在墓地存在的最多3只怪兽回到持有者卡组。
function c10537981.initial_effect(c)
	-- 结束阶段时才能发动。可以使这个回合被破坏的在墓地存在的最多3只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(c10537981.condition)
	e1:SetTarget(c10537981.target)
	e1:SetOperation(c10537981.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：只有当前阶段为结束阶段时，该卡才能发动。
function c10537981.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前游戏阶段是否为结束阶段（PHASE_END），作为发动时点限制。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 定义筛选函数：选择本回合被破坏（REASON_DESTROY）、是怪兽、当前回合进入墓地（GetTurnID()==tid）且可以返回卡组的墓地怪兽。
function c10537981.filter(c,tid)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid
		and c:IsAbleToDeck()
end
-- 处理发动时的目标选择：检查是否有合法对象，提示玩家从双方墓地选择1~3只满足条件的怪兽，并登记操作信息。
function c10537981.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时校验对象：若系统询问某张卡是否可选，则要求它位于墓地且满足筛选条件。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c10537981.filter(chkc,Duel.GetTurnCount()) end
	-- 发动合法性检查：确认墓地中至少存在1只满足条件的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c10537981.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,Duel.GetTurnCount()) end
	-- 弹出选择提示信息，告知玩家正在选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方墓地选择1~3只满足条件的怪兽作为此效果的对象。
	local g=Duel.SelectTarget(tp,c10537981.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil,Duel.GetTurnCount())
	-- 设定操作信息：将选中的对象组g登记为回卡组（CATEGORY_TODECK）效果，数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：取回发动时选择的对象，过滤掉已不关联的卡，将剩余卡送回持有者卡组并洗牌。
function c10537981.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的对象卡组（发动时选择的目标）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后的对象卡以效果原因送回持有者卡组，使用SEQ_DECKSHUFFLE表示送回后洗牌。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
