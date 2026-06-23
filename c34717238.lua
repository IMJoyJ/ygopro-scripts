--畳返し
-- 效果：
-- 召唤成功时发动的效果怪兽的发动和效果无效，那只怪兽破坏。
function c34717238.initial_effect(c)
	-- 创建并注册一张发动时效果，连锁时触发，使怪兽召唤成功时发动的效果无效并破坏那只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34717238.condition)
	e1:SetTarget(c34717238.target)
	e1:SetOperation(c34717238.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数
function c34717238.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的效果是否为怪兽类型、是否为召唤成功事件且该连锁可被无效
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 设置效果处理时的操作信息，包括使效果无效和可能的破坏
function c34717238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏发动效果的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应怪兽
function c34717238.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且发动怪兽仍存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
