--邪気退散
-- 效果：
-- 丢弃1张手卡。场上表侧表示存在的永续陷阱卡全部破坏。
function c13626450.initial_effect(c)
	-- 丢弃1张手卡。场上表侧表示存在的永续陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13626450.cost)
	e1:SetTarget(c13626450.target)
	e1:SetOperation(c13626450.activate)
	c:RegisterEffect(e1)
end
-- 检查是否可以丢弃1张手卡，若可以则执行丢弃操作。
function c13626450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家手牌中是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手牌，丢弃原因为效果支付代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选场上表侧表示的永续陷阱卡。
function c13626450.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20004)==0x20004
end
-- 设置连锁处理信息，确定将要破坏的卡片组。
function c13626450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的永续陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有满足条件的永续陷阱卡组成的卡片组。
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，将要破坏的卡片数量和类型设定为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将符合条件的卡片全部破坏。
function c13626450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的永续陷阱卡组成的卡片组。
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因将卡片组全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
