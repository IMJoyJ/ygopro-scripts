--対抗魔術
-- 效果：
-- 把自己场上存在的2个魔力指示物取除发动。魔法卡的发动无效并破坏。
function c53112492.initial_effect(c)
	-- 效果发动时，将自身场上的2个魔力指示物取除作为费用，使魔法卡的发动无效并破坏
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
c53112492.mentioned_counter={
	[0x1]=true,
}
-- 魔法卡的发动无效并破坏
function c53112492.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 支付费用：移除自己场上存在的2个魔力指示物
function c53112492.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能移除2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 执行移除2个魔力指示物的操作
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏目标卡片
function c53112492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使连锁发动无效并破坏对应魔法卡
function c53112492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡片有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 执行破坏目标卡片的操作
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
