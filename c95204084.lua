--コアキメイル・トルネード
-- 效果：
-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。对方场上存在的特殊召唤的怪兽全部破坏。
function c95204084.initial_effect(c)
	-- 将「核成兽的钢核」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,36623431)
	-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。对方场上存在的特殊召唤的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95204084,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95204084.cost)
	e1:SetTarget(c95204084.target)
	e1:SetOperation(c95204084.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡名为「核成兽的钢核」且能作为代价送回卡组的卡
function c95204084.cfilter(c)
	return c:IsCode(36623431) and c:IsAbleToDeckAsCost()
end
-- 发动代价：从手卡让1张「核成兽的钢核」回到卡组最上面
function c95204084.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95204084.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c95204084.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为发动代价送回卡组最上面
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤条件：特殊召唤的怪兽
function c95204084.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果的目标：检查对方场上是否存在特殊召唤的怪兽，并设置破坏的操作信息
function c95204084.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95204084.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c95204084.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏对方场上的这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的处理：破坏对方场上所有特殊召唤的怪兽
function c95204084.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c95204084.filter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
