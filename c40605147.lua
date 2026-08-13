--神の通告
-- 效果：
-- ①：可以支付1500基本分把以下效果发动。
-- ●怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c40605147.initial_effect(c)
	-- ①：可以支付1500基本分把以下效果发动。●怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c40605147.condition)
	e1:SetCost(c40605147.cost)
	e1:SetTarget(c40605147.target)
	e1:SetOperation(c40605147.activate)
	c:RegisterEffect(e1)
	-- ①：可以支付1500基本分把以下效果发动。●自己或对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	-- 为第二个效果设置发动条件，使用aux.NegateSummonCondition确保当前没有处理中的连锁时才能发动，满足“特殊召唤之际发动”的时点要求。
	e2:SetCondition(aux.NegateSummonCondition)
	e2:SetCost(c40605147.cost)
	e2:SetTarget(c40605147.target1)
	e2:SetOperation(c40605147.activate1)
	c:RegisterEffect(e2)
end
-- 定义第一个效果的发动条件函数：检查当前发动的效果是否为怪兽效果且该效果的连锁能否被无效化。
function c40605147.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动中的效果re是怪兽效果，并且当前连锁可以被无效，从而满足“怪兽的效果发动时才能发动”的条件。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义效果的发动代价函数：在发动时检查和支付1500基本分作为代价。
function c40605147.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）检查玩家tp是否能支付1500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 实际支付1500基本分作为发动代价。
	Duel.PayLPCost(tp,1500)
end
-- 定义第一个效果的发动时目标处理函数：登记无效并破坏的对象；若被无效的怪兽可被效果破坏，则同时登记破坏信息。
function c40605147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明将无效当前连锁的怪兽效果，目标为触发该效果的怪兽（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，声明若该怪兽可被破坏则将其破坏（eg）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义第一个效果的解决处理：若怪兽效果的发动被成功无效，并且其效果来源卡仍与效果关联，则将那只怪兽破坏。
function c40605147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该怪兽效果的发动，并确认效果来源怪兽仍与那个效果保持关联（未被离场等原因重置）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏的方式破坏被无效发动的那只怪兽（eg）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义第二个效果的发动时目标处理函数：登记将无效的特殊召唤以及相应破坏的怪兽。
function c40605147.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明将无效这次特殊召唤，对象为正在特殊召唤的所有怪兽（eg）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息，声明将破坏这些正被特殊召唤的怪兽（eg），数量为eg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义第二个效果的解决处理：使那次特殊召唤无效，并将那些怪兽破坏。
function c40605147.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在特殊召唤的怪兽（eg）的特殊召唤无效。
	Duel.NegateSummon(eg)
	-- 以效果破坏的方式破坏那些因特殊召唤被无效的怪兽（eg）。
	Duel.Destroy(eg,REASON_EFFECT)
end
