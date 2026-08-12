--インヴェルズ・ローチ
-- 效果：
-- 4星怪兽×2
-- 可以把这张卡1个超量素材取除，5星以上的怪兽的特殊召唤无效并破坏。
function c37926346.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4且数量为2的怪兽作为素材
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 5星以上的怪兽的特殊召唤无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(37926346,0))  --"5星以上的怪兽的特殊召唤无效并破坏"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c37926346.condition)
	e1:SetCost(c37926346.cost)
	e1:SetTarget(c37926346.target)
	e1:SetOperation(c37926346.operation)
	c:RegisterEffect(e1)
end
-- 筛选等级为5以上的怪兽
function c37926346.filter(c)
	return c:IsLevelAbove(5)
end
-- 判断当前连锁为0且存在等级5以上的怪兽
function c37926346.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0且存在等级5以上的怪兽
	return Duel.GetCurrentChain()==0 and eg:IsExists(c37926346.filter,1,nil)
end
-- 支付1个超量素材作为代价
function c37926346.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理时要无效召唤和破坏的怪兽
function c37926346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c37926346.filter,nil)
	-- 设置要无效召唤的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置要破坏的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果，使怪兽召唤无效并破坏
function c37926346.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c37926346.filter,nil)
	-- 使目标怪兽的召唤无效
	Duel.NegateSummon(g)
	-- 以效果为原因破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
