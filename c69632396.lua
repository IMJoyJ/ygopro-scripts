--ゴブリンのその場しのぎ
-- 效果：
-- 支付500基本分。魔法卡的发动无效，那张卡回到持有者的手卡。
function c69632396.initial_effect(c)
	-- 支付500基本分。魔法卡的发动无效，那张卡回到持有者的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c69632396.condition)
	e1:SetCost(c69632396.cost)
	e1:SetTarget(c69632396.target)
	e1:SetOperation(c69632396.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否能发动此卡
function c69632396.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁中的卡片是否为魔法卡的发动，且该发动是否可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义Cost函数，处理发动此卡所需的代价
function c69632396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 在发动时，让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 定义Target函数，用于设置效果分类和操作信息
function c69632396.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表明此效果包含将卡片加入手牌的操作
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 定义Operation函数，处理效果的具体执行
function c69632396.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 如果成功使该魔法卡的发动无效，且该卡仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将该魔法卡送回持有者的手牌
		Duel.SendtoHand(ec,nil,REASON_EFFECT)
	end
end
