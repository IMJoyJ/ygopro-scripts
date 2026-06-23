--盗賊の七つ道具
-- 效果：
-- ①：陷阱卡发动时，支付1000基本分才能发动。那个发动无效并破坏。
function c3819470.initial_effect(c)
	-- 创建效果对象并设置其类型为陷阱卡发动时的响应效果，包含无效和破坏两个效果分类
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3819470.condition)
	e1:SetCost(c3819470.cost)
	e1:SetTarget(c3819470.target)
	e1:SetOperation(c3819470.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数
function c3819470.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保连锁的发动是陷阱卡的发动且可以被无效
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 支付1000基本分的费用函数
function c3819470.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置效果的目标，确定要无效和可能破坏的卡
function c3819470.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使连锁发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将破坏发动的陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理函数，执行无效和破坏操作
function c3819470.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且原卡仍存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏发动的陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
