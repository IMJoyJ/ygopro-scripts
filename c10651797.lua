--ツバメ返し
-- 效果：
-- 特殊召唤成功时发动的效果怪兽的效果的发动无效并破坏。
function c10651797.initial_effect(c)
	-- 特殊召唤成功时发动的效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c10651797.condition)
	e1:SetTarget(c10651797.target)
	e1:SetOperation(c10651797.activate)
	c:RegisterEffect(e1)
end
-- 检查是否为怪兽卡特殊召唤成功发动的连锁
function c10651797.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认该连锁可以被无效，且为怪兽特殊召唤成功事件
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SPSUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 设置效果处理目标
function c10651797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置将破坏发动怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数
function c10651797.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并确认效果怪兽仍存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏效果怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
