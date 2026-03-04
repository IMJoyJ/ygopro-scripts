--邪気退散
-- 效果：
-- 丢弃1张手卡。场上表侧表示存在的永续陷阱卡全部破坏。
function c13626450.initial_effect(c)
	-- 效果原文内容：丢弃1张手卡。场上表侧表示存在的永续陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13626450.cost)
	e1:SetTarget(c13626450.target)
	e1:SetOperation(c13626450.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足丢弃手卡的条件
function c13626450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将目标怪兽特殊召唤
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用
function c13626450.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20004)==0x20004
end
-- 效果作用
function c13626450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取满足条件的卡片组
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用
function c13626450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡片组
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将目标怪兽特殊召唤
	Duel.Destroy(g,REASON_EFFECT)
end
