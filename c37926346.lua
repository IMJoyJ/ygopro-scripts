--インヴェルズ・ローチ
-- 效果：
-- 4星怪兽×2
-- 可以把这张卡1个超量素材取除，5星以上的怪兽的特殊召唤无效并破坏。
function c37926346.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：不限制素材条件，使用2只4星怪兽叠放进行XYZ召唤，对应召唤条件4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 可以把这张卡1个超量素材取除，5星以上的怪兽的特殊召唤无效并破坏。
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
-- 定义筛选函数：筛选出等级5以上的怪兽，用于识别将被无效并破坏的特殊召唤怪兽。
function c37926346.filter(c)
	return c:IsLevelAbove(5)
end
-- 定义效果发动条件：当前连锁数为0，且本次特殊召唤的怪兽组中有至少1只等级5以上的怪兽。
function c37926346.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前不在连锁处理中且存在等级5以上的特殊召唤怪兽，满足这两个条件时效果才能发动。
	return Duel.GetCurrentChain()==0 and eg:IsExists(c37926346.filter,1,nil)
end
-- 定义代价处理：发动前检查能否取除1个超量素材；能则实际取除这张卡的1个超量素材作为发动代价。
function c37926346.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果发动时的对象处理：筛选出等级5以上的特殊召唤怪兽组，并将其登记为无效召唤与破坏的对象。
function c37926346.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c37926346.filter,nil)
	-- 将筛选出的怪兽组登记为无效召唤的对象，数量为组内怪兽数，便于系统识别无效召唤分类。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 将同一组怪兽登记为破坏的对象，数量为组内怪兽数，便于系统识别破坏分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理：筛选出本次特殊召唤中等级5以上的怪兽，将它们特殊召唤无效并破坏。
function c37926346.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c37926346.filter,nil)
	-- 使该组正在特殊召唤的怪兽的特殊召唤无效。
	Duel.NegateSummon(g)
	-- 将特殊召唤被无效的怪兽以效果原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
