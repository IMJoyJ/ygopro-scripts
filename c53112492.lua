--対抗魔術
-- 效果：
-- 把自己场上存在的2个魔力指示物取除发动。魔法卡的发动无效并破坏。
function c53112492.initial_effect(c)
	-- 创建效果，设置效果分类为无效和破坏，类型为发动，触发事件为连锁发动，条件、费用、目标和效果处理函数分别为对应的函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c53112492.condition)
	e1:SetCost(c53112492.cost)
	e1:SetTarget(c53112492.target)
	e1:SetOperation(c53112492.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断
function c53112492.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保连锁的发动是魔法卡且为发动类型，并且可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 支付费用时的处理函数
function c53112492.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除2个魔力指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 移除自己场上的2个魔力指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 设置效果处理时的目标信息
function c53112492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果魔法卡可被破坏则设置破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应魔法卡
function c53112492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并且魔法卡与效果相关时进行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对应的魔法卡以效果为原因进行破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
