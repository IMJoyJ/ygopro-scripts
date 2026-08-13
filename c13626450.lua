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
-- 发动代价：从手卡丢弃1张卡。
function c13626450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在1张可以丢弃的卡，以满足发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手卡选择1张可以丢弃的卡丢弃，丢弃原因记为费用与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：场上表侧表示且为永续陷阱卡。
function c13626450.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20004)==0x20004
end
-- 发动时处理：确认存在符合条件的卡，获取全部此类卡并预设破坏信息。
function c13626450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张表侧表示的永续陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有表侧表示的永续陷阱卡。
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将上述卡片登记为本次效果将破坏的对象，数量为集合中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：再次获取场上所有表侧表示的永续陷阱卡，并将其全部破坏。
function c13626450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示的永续陷阱卡。
	local g=Duel.GetMatchingGroup(c13626450.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些卡全部破坏，破坏原因记为效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
