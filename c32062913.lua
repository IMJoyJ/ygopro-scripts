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
-- 代价函数：作为发动的代价，把自己场上的10个魔力指示物取除。
function c32062913.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可移除的10个魔力指示物，以此决定能否发动。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,10,REASON_COST) end
	-- 作为发动的代价，把自己场上存在的10个魔力指示物取除。
	Duel.RemoveCounter(tp,1,0,0x1,10,REASON_COST)
end
-- 对象选择函数：确认对方场上存在卡，并把对方场上全部卡设为破坏的操作信息。
function c32062913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡，以此决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得对方场上存在的所有卡作为破坏对象组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：对方场上存在的卡全部破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：把对方场上存在的卡全部破坏。
function c32062913.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上存在的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因把对方场上存在的卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
