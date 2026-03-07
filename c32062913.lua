--メガトン魔導キャノン
-- 效果：
-- 把自己场上存在的10个魔力指示物取除发动。对方场上存在的卡全部破坏。
function c32062913.initial_effect(c)
	-- 效果原文：把自己场上存在的10个魔力指示物取除发动。对方场上存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32062913.cost)
	e1:SetTarget(c32062913.target)
	e1:SetOperation(c32062913.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否能移除10个魔力指示物并执行移除操作
function c32062913.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以移除10个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,10,REASON_COST) end
	-- 规则层面：移除玩家场上的10个魔力指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,10,REASON_COST)
end
-- 效果作用：设置连锁处理的目标为对方场上所有卡
function c32062913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查对方场上是否存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面：获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面：设置连锁操作信息为破坏效果，目标为对方场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏对方场上所有卡的效果
function c32062913.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取对方场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面：将对方场上所有卡以效果为原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
