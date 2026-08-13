--盗賊の七つ道具
-- 效果：
-- ①：陷阱卡发动时，支付1000基本分才能发动。那个发动无效并破坏。
function c3819470.initial_effect(c)
	-- ①：陷阱卡发动时，支付1000基本分才能发动。那个发动无效并破坏。
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
-- 定义发动条件：当前连锁上的效果必须是陷阱卡且属于陷阱卡的发动，并且该连锁的发动能够被无效。
function c3819470.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发连锁的效果是否为陷阱卡、是否为陷阱卡发动（EFFECT_TYPE_ACTIVATE），同时确认该连锁可以被无效。
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义发动代价：需要支付1000基本分。先进行是否存在可支付代价的检查，再实际扣除基本分。
function c3819470.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 定义发动时的目标与效果信息：对正在发动的陷阱卡进行无效，并视情况附加破坏该卡的效果信息。
function c3819470.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含使那次发动无效（CATEGORY_NEGATE），对象为当前连锁中的那张陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该陷阱卡能够被破坏且仍与效果相关联，则额外设置破坏（CATEGORY_DESTROY）的操作信息，对象同样是那张陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理阶段：先无效对方那张陷阱卡的发动，若无效成功且该卡仍未离场或与效果关联，则将其破坏。
function c3819470.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该连锁，并且那张陷阱卡仍与这个效果保持关联（没有被除外、送墓或离开场上等），满足时才能继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）将正在发动的陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
