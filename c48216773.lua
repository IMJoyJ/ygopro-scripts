--強制退出装置
-- 效果：
-- 双方各自选自己场上1只怪兽，那些怪兽回到持有者卡组。
function c48216773.initial_effect(c)
	-- 创建效果，设置为发动时点，将卡牌送回卡组
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c48216773.target)
	e1:SetOperation(c48216773.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件，双方场上各至少有1只可送回卡组的怪兽
function c48216773.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少1只可送回卡组的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否有至少1只可送回卡组的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息，确定将要处理的2张卡牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果发动时执行的操作，双方各自选择1只怪兽送回卡组
function c48216773.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上的1只可送回卡组的怪兽
	local dg1=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示对方玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上的1只可送回卡组的怪兽
	local dg2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_MZONE,0,1,1,nil)
	dg1:Merge(dg2)
	-- 显示所选怪兽被选为对象的动画效果
	Duel.HintSelection(dg1)
	-- 将选中的怪兽以洗牌方式送回卡组
	Duel.SendtoDeck(dg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
