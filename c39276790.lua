--真剣勝負
-- 效果：
-- ①：伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c39276790.initial_effect(c)
	-- 效果原文内容：①：伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c39276790.condition)
	e1:SetTarget(c39276790.target)
	e1:SetOperation(c39276790.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否在伤害步骤或伤害计算阶段，且发动的卡是怪兽效果或魔法/陷阱卡，同时该连锁可以被无效。
function c39276790.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 效果作用：判断当前连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置连锁处理时的操作信息，包括使发动无效和可能的破坏
function c39276790.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置破坏发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行效果，先使连锁无效，再破坏发动卡
function c39276790.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：先使连锁无效，再判断发动卡是否与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：以效果原因破坏发动卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
