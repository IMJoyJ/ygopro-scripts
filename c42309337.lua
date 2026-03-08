--カウンター・カウンター
-- 效果：
-- 反击陷阱卡的发动无效并破坏。
function c42309337.initial_effect(c)
	-- 反击陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42309337.condition)
	e1:SetTarget(c42309337.target)
	e1:SetOperation(c42309337.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c42309337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用
	return re:GetHandler():IsType(TYPE_COUNTER) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果作用
function c42309337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用
function c42309337.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且原卡仍有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
