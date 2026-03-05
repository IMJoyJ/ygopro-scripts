--トラップ・ジャマー
-- 效果：
-- 战斗阶段中才能发动。对方发动的陷阱卡的发动无效并破坏。
function c19252988.initial_effect(c)
	-- 效果原文内容：战斗阶段中才能发动。对方发动的陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c19252988.condition)
	e1:SetTarget(c19252988.target)
	e1:SetOperation(c19252988.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否在战斗阶段中，且对方发动的是陷阱卡，且该连锁可以被无效。
function c19252988.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=0x08 and ph<=0x20 and tp~=ep and re:IsActiveType(TYPE_TRAP)
		-- 效果作用：确认对方发动的是陷阱卡且为发动类型，且该连锁可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置连锁处理时的操作信息，包括使对方陷阱卡发动无效和可能的破坏。
function c19252988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理时的操作信息，将对方陷阱卡发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置连锁处理时的操作信息，将对方陷阱卡破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行连锁无效和破坏操作。
function c19252988.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使对方陷阱卡发动无效，并检查该陷阱卡是否与效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：将对方陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
