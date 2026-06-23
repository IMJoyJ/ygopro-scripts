--セイクリッド・ヒアデス
-- 效果：
-- 光属性3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上存在的怪兽全部变成表侧守备表示。
function c47579719.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足光属性条件的3星怪兽作为素材进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上存在的怪兽全部变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetDescription(aux.Stringid(47579719,0))  --"变成表侧守备表示"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c47579719.cost)
	e1:SetTarget(c47579719.target)
	e1:SetOperation(c47579719.operation)
	c:RegisterEffect(e1)
end
-- 费用处理函数，检查是否可以移除1个超量素材作为发动代价并执行移除操作
function c47579719.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选出不是表侧守备表示且可以改变表示形式的怪兽
function c47579719.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 目标选择函数，检查对方场上是否存在至少1只满足过滤条件的怪兽
function c47579719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足目标选择条件，即对方场上存在至少1只非表侧守备表示且可改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47579719.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果发动时执行的操作函数，获取所有满足条件的对方怪兽并将其变为表侧守备表示
function c47579719.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足过滤条件的怪兽组成一个组
	local g=Duel.GetMatchingGroup(c47579719.filter,tp,0,LOCATION_MZONE,nil)
	-- 将指定怪兽组全部改变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
end
