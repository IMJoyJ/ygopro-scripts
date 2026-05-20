--グリフォンの翼
-- 效果：
-- ①：对方把「鹰身女妖的羽毛扫」发动时才能发动。那个效果无效，对方场上的魔法·陷阱卡全部破坏。
function c55608151.initial_effect(c)
	-- ①：对方把「鹰身女妖的羽毛扫」发动时才能发动。那个效果无效，对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c55608151.condition)
	e1:SetTarget(c55608151.target)
	e1:SetOperation(c55608151.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c55608151.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法·陷阱卡的发动，且该卡是「鹰身女妖的羽毛扫」，并且该连锁效果可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(18144506) and Duel.IsChainDisablable(ev)
end
-- 过滤场上的魔法·陷阱卡
function c55608151.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果的目标与操作信息设置函数
function c55608151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55608151.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c55608151.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏对方场上的所有魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理的执行函数
function c55608151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效，若成功则继续处理
	if Duel.NegateEffect(ev) then
		-- 获取对方场上所有的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c55608151.filter,tp,0,LOCATION_ONFIELD,nil)
		-- 破坏对方场上的所有魔法·陷阱卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
