--魔力浄化
-- 效果：
-- 丢弃1张手卡。场上表侧表示存在的永续魔法全部破坏。
function c1669772.initial_effect(c)
	-- 效果原文：丢弃1张手卡。场上表侧表示存在的永续魔法全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1669772.cost)
	e1:SetTarget(c1669772.target)
	e1:SetOperation(c1669772.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的卡片组并丢弃1张手卡作为代价。
function c1669772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家手牌中是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：丢弃1张手牌作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：过滤函数，筛选场上表侧表示的永续魔法卡。
function c1669772.filter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 效果作用：设置连锁处理信息，确定要破坏的永续魔法卡。
function c1669772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在满足条件的永续魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 效果作用：获取场上满足条件的永续魔法卡组。
	local g=Duel.GetMatchingGroup(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 效果作用：设置连锁操作信息，指定破坏的卡组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏场上满足条件的永续魔法卡。
function c1669772.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上满足条件的永续魔法卡组。
	local g=Duel.GetMatchingGroup(c1669772.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 效果作用：以效果原因破坏指定的永续魔法卡。
	Duel.Destroy(g,REASON_EFFECT)
end
