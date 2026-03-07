--猛突進
-- 效果：
-- 选择自己场上表侧表示存在的1只兽族怪兽破坏，选择对方场上存在的1只怪兽回到卡组。
function c32854013.initial_effect(c)
	-- 效果原文内容：选择自己场上表侧表示存在的1只兽族怪兽破坏，选择对方场上存在的1只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c32854013.target)
	e1:SetOperation(c32854013.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的兽族怪兽（表侧表示）
function c32854013.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 效果作用：判断是否满足发动条件
function c32854013.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断自己场上是否存在满足条件的兽族怪兽
	if chk==0 then return Duel.IsExistingTarget(c32854013.dfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：判断对方场上是否存在可以回到卡组的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的1只自己场上的兽族怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,c32854013.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 效果作用：向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择满足条件的1只对方场上的怪兽作为返回卡组对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 效果作用：设置返回卡组效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
-- 效果原文内容：选择自己场上表侧表示存在的1只兽族怪兽破坏，选择对方场上存在的1只怪兽回到卡组。
function c32854013.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 效果作用：获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	-- 效果作用：判断破坏和返回卡组的怪兽是否仍然有效
	if tc1:IsRelateToEffect(e) and c32854013.dfilter(tc1) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(tc2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
