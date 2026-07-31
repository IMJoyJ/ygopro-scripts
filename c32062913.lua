--メガトン魔導キャノン
-- 效果：
-- 把自己场上存在的10个魔力指示物取除发动。对方场上存在的卡全部破坏。
function c32062913.initial_effect(c)
	-- 把自己场上存在的10个魔力指示物取除发动。对方场上存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32062913.cost)
	e1:SetTarget(c32062913.target)
	e1:SetOperation(c32062913.activate)
	c:RegisterEffect(e1)
end
c32062913.mentioned_counter={
	[0x1]=true,
}
-- 检查是否可以移除10个魔力指示物作为代价并执行移除操作。
function c32062913.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能移除10个魔力指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,10,REASON_COST) end
	-- 移除10个魔力指示物。
	Duel.RemoveCounter(tp,1,0,0x1,10,REASON_COST)
end
-- 检查对方场上是否存在卡，并设置破坏效果的目标信息。
function c32062913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少一张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡组成的组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息，指定将要破坏的卡组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将对方场上的所有卡破坏。
function c32062913.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡组成的组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏指定卡组。
	Duel.Destroy(g,REASON_EFFECT)
end
