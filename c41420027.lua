--神の宣告
-- 效果：
-- ①：可以把基本分支付一半把以下效果发动。
-- ●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c41420027.initial_effect(c)
	-- 创建一个效果，用于处理召唤时的无效和破坏效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 判断当前是否存在尚未结算的连锁环节，确保效果只能在非连锁状态下发动
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c41420027.cost1)
	e1:SetTarget(c41420027.target1)
	e1:SetOperation(c41420027.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- 创建一个效果，用于处理魔法·陷阱卡发动时的无效和破坏效果
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c41420027.condition2)
	e4:SetCost(c41420027.cost2)
	e4:SetTarget(c41420027.target2)
	e4:SetOperation(c41420027.activate2)
	c:RegisterEffect(e4)
end
-- 支付一半基本分作为发动成本
function c41420027.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为发动成本
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置操作信息，标记将要无效召唤并破坏目标怪兽
function c41420027.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记将要无效召唤效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息，标记将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行召唤无效和破坏操作
function c41420027.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 判断是否为魔法·陷阱卡发动且该连锁可以被无效
function c41420027.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为魔法·陷阱卡发动且该连锁可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 支付一半基本分作为发动成本
function c41420027.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为发动成本
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置操作信息，标记将要无效发动并可能破坏目标卡
function c41420027.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记将要无效发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，标记将要破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行发动无效和破坏操作
function c41420027.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动无效是否成功且目标卡存在并关联到效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
