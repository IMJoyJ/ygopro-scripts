--スリーカード
-- 效果：
-- 自己场上有衍生物以外的同名怪兽3只以上存在的场合才能发动。选择对方场上3张卡破坏。
function c47594192.initial_effect(c)
	-- 效果原文内容：自己场上有衍生物以外的同名怪兽3只以上存在的场合才能发动。选择对方场上3张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c47594192.condition)
	e1:SetTarget(c47594192.target)
	e1:SetOperation(c47594192.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在满足条件的怪兽（非衍生物且存在至少2个同名怪兽）
function c47594192.cfilter(c,tp)
	-- 效果作用：检查场上是否存在满足条件的怪兽（非衍生物且存在至少2个同名怪兽）
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and Duel.IsExistingMatchingCard(c47594192.cfilter2,tp,LOCATION_MZONE,0,2,c,c:GetCode())
end
-- 效果作用：检查指定code的怪兽是否在场面上
function c47594192.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 效果作用：判断自己场上是否存在满足条件的怪兽（非衍生物且存在至少2个同名怪兽）
function c47594192.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否存在满足条件的怪兽（非衍生物且存在至少2个同名怪兽）
	return Duel.IsExistingMatchingCard(c47594192.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 效果原文内容：选择对方场上3张卡破坏。
function c47594192.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果作用：检查是否满足选择3张对方场上的卡作为对象的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,3,nil) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择对方场上的3张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,3,3,nil)
	-- 效果作用：设置本次连锁操作信息为破坏效果，目标为选中的3张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
end
-- 效果原文内容：选择对方场上3张卡破坏。
function c47594192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中指定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：以效果原因将目标卡组进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
