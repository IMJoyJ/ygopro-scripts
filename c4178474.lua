--サンダー・ブレイク
-- 效果：
-- ①：丢弃1张手卡，以场上1张卡为对象才能发动。那张卡破坏。
function c4178474.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,0x11e0)
	e1:SetCost(c4178474.cost)
	e1:SetTarget(c4178474.target)
	e1:SetOperation(c4178474.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足丢弃手卡的条件并执行丢弃操作
function c4178474.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否场上有满足条件的卡可以成为对象
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：选择破坏对象并设置操作信息
function c4178474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 效果作用：判断是否场上有满足条件的卡可以成为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置连锁操作信息，标记为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：处理效果发动，对目标卡进行破坏
function c4178474.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
