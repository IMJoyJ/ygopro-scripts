--強制退出装置
-- 效果：
-- 双方各自选自己场上1只怪兽，那些怪兽回到持有者卡组。
function c48216773.initial_effect(c)
	-- 双方各自选自己场上1只怪兽，那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c48216773.target)
	e1:SetOperation(c48216773.activate)
	c:RegisterEffect(e1)
end
-- 发动效果的判定：检查双方场上是否各自存在至少1只满足“可以回到卡组”的怪兽，若任一方的怪兽区没有符合条件的怪兽则不能发动。
function c48216773.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在至少1只满足“可以回到卡组”的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方主要怪兽区是否存在至少1只满足“可以回到卡组”的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：预计将双方怪兽区合计2只怪兽返回卡组，因具体对象在效果处理时选择，故对象暂记为nil，涉及玩家为双方，位置为主要怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果处理：分别让双方玩家各自从自己场上选择1只怪兽，将选择的怪兽合并后一起返回持有者卡组并洗牌。
function c48216773.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家弹出选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 当前玩家从自己主要怪兽区选择1张满足“可以回到卡组”的怪兽。
	local dg1=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给对方玩家弹出选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 对方玩家从自己主要怪兽区选择1张满足“可以回到卡组”的怪兽。
	local dg2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_MZONE,0,1,1,nil)
	dg1:Merge(dg2)
	-- 为最终选中的怪兽组显示被选为对象的动画，并记录这些卡被选为对象。
	Duel.HintSelection(dg1)
	-- 将双方选中的怪兽以效果原因送回持有者卡组，并置于卡组最顶端后洗切卡组。
	Duel.SendtoDeck(dg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
