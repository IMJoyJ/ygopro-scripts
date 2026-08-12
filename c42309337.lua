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
-- 定义条件函数，检查连锁是否为可无效的反击陷阱卡发动。
function c42309337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的卡是否为反击陷阱类型且正在发动，以及该连锁能否被无效。
	return re:GetHandler():IsType(TYPE_COUNTER) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义目标函数，设置操作信息为无效发动和可能破坏。
function c42309337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效发动，目标为连锁的卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏，目标为连锁的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义操作函数，执行无效发动和破坏效果。
function c42309337.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功且目标卡仍与效果有关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏目标卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
