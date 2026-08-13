--神の宣告
-- 效果：
-- ①：可以把基本分支付一半把以下效果发动。
-- ●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c41420027.initial_effect(c)
	-- ①：可以把基本分支付一半把以下效果发动。●自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设定召唤无效效果的发动条件：当前没有正在处理的连锁（即只能直接在召唤之际发动），由aux.NegateSummonCondition保证。
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
	-- ①：可以把基本分支付一半把以下效果发动。●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
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
-- 代价函数：在chk==0（效果发动合法性检查）时返回true，实际发动时调用Duel.PayLPCost支付一半LP；这是召唤无效效果分支的代价。
function c41420027.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 目标/操作信息设定函数：本效果不取对象，chk==0时直接返回true；随后将正在召唤/特殊召唤的怪兽组eg登记为无效召唤与破坏的对象，数量为eg的数量，供效果处理时使用。
function c41420027.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果将无效召唤，涉及目标为eg中的所有怪兽，数量为eg:GetCount()，用于连锁相关判定与效果提示。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 登记操作信息：本次效果将在无效召唤后将那些怪兽破坏，目标同为eg中的所有怪兽，数量为eg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤无效效果的处理函数：先通过Duel.NegateSummon(eg)使召唤无效，随后用Duel.Destroy(eg,REASON_EFFECT)将这些怪兽破坏。
function c41420027.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 对正在召唤/反转召唤/特殊召唤的怪兽组eg执行召唤无效，使它们的召唤不成功。
	Duel.NegateSummon(eg)
	-- 将召唤被无效的怪兽组eg以效果原因（REASON_EFFECT）破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 魔法·陷阱卡发动无效效果的发动条件函数：判断当前连锁中的效果是否为魔法·陷阱卡的发动，且该连锁可以被无效。
function c41420027.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当：触发效果re是魔法·陷阱卡发动（EFFECT_TYPE_ACTIVATE）且当前连锁ev可被无效化。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价函数（魔法陷阱无效分支）：chk==0时返回true，实际发动时支付当前LP的一半，与召唤无效分支的代价相同。
function c41420027.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 目标/操作信息设定函数：本效果不取对象，chk==0时直接返回true；先将当前发动的那张魔/陷（eg）登记为无效化对象，若它的控制者/场上状态仍可被破坏且与发动效果关联，则再登记为破坏对象。
function c41420027.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果将无效该魔法·陷阱卡的发动，对象为eg（即正在发动的魔/陷），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：本次效果将破坏那张发动无效化的魔/陷，对象仍为eg，数量为1（仅在卡片可破坏且与效果关联时设置）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法陷阱无效效果的处理函数：先尝试无效连锁ev的发动；若无效成功且被无效的卡仍与效果关联，则将该卡破坏。
function c41420027.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查条件：Duel.NegateActivation(ev)成功无效了该连锁的发动，且re:GetHandler()仍然与re存在关联（没有被中途离场等情况重置）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的那张魔法·陷阱卡（eg）以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
