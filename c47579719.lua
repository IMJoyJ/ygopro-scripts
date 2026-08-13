--セイクリッド・ヒアデス
-- 效果：
-- 光属性3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上存在的怪兽全部变成表侧守备表示。
function c47579719.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用2只光属性3星怪兽作为超量素材叠放进行超量召唤。
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
-- 发动代价处理：效果发动前检查这张卡是否有1个超量素材可作为代价移除；检查通过后，实际移除这张卡的1个超量素材作为发动代价。
function c47579719.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选效果处理对象：怪兽不是表侧守备表示，并且当前可以变更表示形式。
function c47579719.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- Target 函数：设定效果发动时需要检查的条件——对方场上存在满足筛选条件的怪兽即可发动；该效果不取对象，不需要指定具体卡片。
function c47579719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时机的合法性检查：若 chk==0，检查对方场上是否至少有1只满足筛选条件的怪兽；没有则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c47579719.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：在效果发动后，先获取符合条件的怪兽集合，然后统一将它们的表示形式改变为表侧守备表示。
function c47579719.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上所有满足筛选条件的怪兽，组成集合g，作为后续变更为表侧守备表示的对象。
	local g=Duel.GetMatchingGroup(c47579719.filter,tp,0,LOCATION_MZONE,nil)
	-- 将集合g中所有怪兽的表示形式统一变更为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
end
