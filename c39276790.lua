--真剣勝負
-- 效果：
-- ①：伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c39276790.initial_effect(c)
	-- 对应效果原文：①：伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c39276790.condition)
	e1:SetTarget(c39276790.target)
	e1:SetOperation(c39276790.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：必须是伤害步骤或伤害计算时，且连锁中发动的是怪兽效果或魔法·陷阱卡的发动，并且该连锁可以被无效。
function c39276790.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 确认当前连锁的发动可以被无效，避免对不能无效的效果发动此卡。
		and Duel.IsChainNegatable(ev)
end
-- 发动处理前的对象/操作信息登记：不取对象，chk=0时直接允许发动；登记无效对象，并根据发动卡是否可破坏且仍关联来追加破坏登记。
function c39276790.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：预定无效当前连锁上发动的效果，对象为连锁事件组eg（即发动中的那张卡）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：如果那张发动卡可以破坏且仍与效果关联，预定将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效并破坏。若无效成功且发动卡仍与效果保持关联，则将eg中的卡破坏。
function c39276790.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 先执行无效连锁ev的发动，并确认发动卡仍与效果关联（未发生对象丢失/离场重置），两个条件均满足才继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将eg中的发动卡破坏，对应效果原文中的“并破坏”。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
