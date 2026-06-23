--神の通告
-- 效果：
-- ①：可以支付1500基本分把以下效果发动。
-- ●怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c40605147.initial_effect(c)
	-- 创建一个效果，用于处理怪兽效果发动时的无效和破坏
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c40605147.condition)
	e1:SetCost(c40605147.cost)
	e1:SetTarget(c40605147.target)
	e1:SetOperation(c40605147.activate)
	c:RegisterEffect(e1)
	-- 创建一个效果，用于处理特殊召唤时的无效和破坏
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	-- 设置该效果的发动条件为当前没有正在进行的连锁
	e2:SetCondition(aux.NegateSummonCondition)
	e2:SetCost(c40605147.cost)
	e2:SetTarget(c40605147.target1)
	e2:SetOperation(c40605147.activate1)
	c:RegisterEffect(e2)
end
-- 判断是否为怪兽卡的效果发动且该连锁可以被无效
function c40605147.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为怪兽卡的效果发动且该连锁可以被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付1500基本分作为发动cost
function c40605147.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏
function c40605147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果，使连锁无效并破坏相关卡片
function c40605147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且相关卡片存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏相关卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 设置特殊召唤时的效果处理信息，包括无效召唤和破坏
function c40605147.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行特殊召唤时的效果，使召唤无效并破坏相关卡片
function c40605147.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	-- 破坏相关卡片
	Duel.Destroy(eg,REASON_EFFECT)
end
