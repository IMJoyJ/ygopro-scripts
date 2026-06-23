--エヴォルカイザー・ソルデ
-- 效果：
-- 恐龙族6星怪兽×2
-- ①：持有超量素材的这张卡不会被效果破坏。
-- ②：对方对怪兽的特殊召唤成功时，把这张卡1个超量素材取除才能发动。那些怪兽破坏。
function c18511599.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足恐龙族条件的怪兽作为素材进行召唤
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
-- 效果适用条件：此卡拥有超量素材时生效
function c18511599.indcon(e)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 过滤条件：对方玩家特殊召唤的怪兽，且该怪兽与当前效果相关
function c18511599.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
-- 支付费用：从自己场上移除1个超量素材作为代价
function c18511599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标：选择对方特殊召唤成功的怪兽作为破坏对象
function c18511599.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c18511599.filter,1,nil,nil,tp) end
	local g=eg:Filter(c18511599.filter,nil,nil,tp)
	-- 设置连锁处理的目标卡片为对方特殊召唤成功的怪兽
	Duel.SetTargetCard(eg)
	-- 设置效果操作信息，指定将要破坏的怪兽数量和类别为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：对符合条件的怪兽进行破坏
function c18511599.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c18511599.filter,nil,e,tp)
	-- 执行破坏操作，将目标怪兽因效果而破坏
	Duel.Destroy(g,REASON_EFFECT)
end
