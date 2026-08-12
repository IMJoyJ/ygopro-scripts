--サンダーエンド・ドラゴン
-- 效果：
-- 8星通常怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡以外的场上存在的怪兽全部破坏。
function c698785.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只8星的通常怪兽作为超量素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_NORMAL),8,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡以外的场上存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(698785,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c698785.cost)
	e1:SetTarget(c698785.target)
	e1:SetOperation(c698785.operation)
	c:RegisterEffect(e1)
end
-- 效果发动代价：取除这张卡的1个超量素材
function c698785.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果的目标选择与可行性检查
function c698785.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只这张卡以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置效果处理信息：破坏场上除这张卡以外的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的具体处理：破坏这张卡以外的场上存在的怪兽
function c698785.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有怪兽（若这张卡已不在场则获取全部）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将这些怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
