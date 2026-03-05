--最終戦争
-- 效果：
-- 丢弃5张手卡。场上的卡全部破坏。
function c18591904.initial_effect(c)
	-- 效果原文内容：丢弃5张手卡。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c18591904.cost)
	e1:SetTarget(c18591904.target)
	e1:SetOperation(c18591904.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：丢弃5张手卡
function c18591904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃5张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,5,e:GetHandler()) end
	-- 执行丢弃5张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,5,5,REASON_COST+REASON_DISCARD)
end
-- 效果作用：设置破坏场上的卡
function c18591904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：破坏场上所有卡
function c18591904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡（排除此卡）的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 执行破坏场上卡的操作
	Duel.Destroy(g,REASON_EFFECT)
end
