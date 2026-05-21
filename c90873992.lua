--戦士抹殺
-- 效果：
-- 场上表侧表示存在的战士族怪兽全部破坏。
function c90873992.initial_effect(c)
	-- 场上表侧表示存在的战士族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90873992.target)
	e1:SetOperation(c90873992.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的战士族怪兽
function c90873992.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
-- 效果发动的目标选择与检测
function c90873992.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90873992.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足过滤条件的怪兽组
	local sg=Duel.GetMatchingGroup(c90873992.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行
function c90873992.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有满足过滤条件的怪兽组
	local sg=Duel.GetMatchingGroup(c90873992.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽因效果破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
