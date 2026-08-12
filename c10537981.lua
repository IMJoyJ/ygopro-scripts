--リターンソウル
-- 效果：
-- 结束阶段时才能发动。可以使这个回合被破坏的在墓地存在的最多3只怪兽回到持有者卡组。
function c10537981.initial_effect(c)
	-- 创建效果对象并设置其分类为回卡组、取对象、发动类型为自由连锁、提示时点为结束阶段、条件为结束阶段、目标函数为target、发动函数为activate
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
-- 效果发动的条件判断函数
function c10537981.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤函数，用于筛选满足条件的墓地怪兽
function c10537981.filter(c,tid)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid
		and c:IsAbleToDeck()
end
-- 效果的目标选择函数
function c10537981.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当目标选择时，判断所选卡片是否满足墓地怪兽且为本回合被破坏的怪兽
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c10537981.filter(chkc,Duel.GetTurnCount()) end
	-- 判断是否满足选择目标的条件，即墓地存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c10537981.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,Duel.GetTurnCount()) end
	-- 向玩家发送提示信息，提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择满足条件的最多3只墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10537981.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil,Duel.GetTurnCount())
	-- 设置效果操作信息，指定将选择的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果的发动处理函数
function c10537981.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽以效果原因送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
