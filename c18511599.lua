--エヴォルカイザー・ソルデ
-- 效果：
-- 恐龙族6星怪兽×2
-- ①：持有超量素材的这张卡不会被效果破坏。
-- ②：对方对怪兽的特殊召唤成功时，把这张卡1个超量素材取除才能发动。那些怪兽破坏。
function c18511599.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以恐龙族6星怪兽2只为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),6,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18511599.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：对方对怪兽的特殊召唤成功时，把这张卡1个超量素材取除才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18511599,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18511599.cost)
	e2:SetTarget(c18511599.target)
	e2:SetOperation(c18511599.operation)
	c:RegisterEffect(e2)
end
-- ①效果的条件判定：这张卡持有超量素材时才适用免疫效果破坏。
function c18511599.indcon(e)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 筛选对方特殊召唤成功的怪兽；若传入效果e，则还需该怪兽仍与本次效果相关联（用于处理时确认没有被除外、离场等导致关系重置）。
function c18511599.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
-- ②效果发动代价：检查并移除这张卡的1个超量素材作为发动COST。
function c18511599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果发动时的合法判定与处理信息设置：确认特殊召唤成功的怪兽中存在对方召唤的怪兽，将这批怪兽设为广义对象，并设置会破坏其中对方怪兽的操作信息。
function c18511599.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c18511599.filter,1,nil,nil,tp) end
	local g=eg:Filter(c18511599.filter,nil,nil,tp)
	-- 将本次特殊召唤成功的全体怪兽（eg）设置为当前连锁的广义对象，使它们与效果建立关联，供处理时确认可否破坏。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：声明将要破坏的对象为g（对方特殊召唤成功的怪兽），数量为g的数量；用于星尘龙、王家长眠之谷等对效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，从特殊召唤成功的怪兽中筛选出仍与效果关联的对方怪兽，然后将其破坏。
function c18511599.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c18511599.filter,nil,e,tp)
	-- 以效果（REASON_EFFECT）为原因破坏这些对方特殊召唤成功的怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
