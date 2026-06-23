--ヴェルズ・ナイトメア
-- 效果：
-- 暗属性4星怪兽×2
-- ①：对方把怪兽特殊召唤时，把这张卡1个超量素材取除才能发动。那些怪兽变成里侧守备表示。
function c359563.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足暗属性条件的4星怪兽作为素材进行召唤，需要2个素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- ①：对方把怪兽特殊召唤时，把这张卡1个超量素材取除才能发动。那些怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(359563,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c359563.cost)
	e1:SetTarget(c359563.target)
	e1:SetOperation(c359563.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：表侧表示、可以转为里侧表示、是对方召唤的、且与当前效果相关
function c359563.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
-- 效果发动时的费用支付，消耗1个超量素材
function c359563.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标，检查是否有满足条件的怪兽，并设置操作信息
function c359563.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c359563.filter,1,nil,nil,tp) end
	-- 将连锁处理的对象设置为对方特殊召唤的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息，指定效果类别为改变表示形式，目标为对方特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理时执行的操作，筛选满足条件的怪兽并将其变为里侧守备表示
function c359563.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c359563.filter,nil,e,tp)
	-- 将指定的怪兽变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
