--畳返し
-- 效果：
-- 召唤成功时发动的效果怪兽的发动和效果无效，那只怪兽破坏。
function c34717238.initial_effect(c)
	-- 召唤成功时发动的效果怪兽的发动和效果无效，那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34717238.condition)
	e1:SetTarget(c34717238.target)
	e1:SetOperation(c34717238.activate)
	c:RegisterEffect(e1)
end
-- 整体发动条件：只有当连锁中的效果是召唤成功时发动的效果怪兽效果，且该连锁能被无效时才允许发动。
function c34717238.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件成立需同时满足：该连锁的效果为怪兽效果、其发动时机是召唤成功、并且该连锁可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 发动时的目标与操作信息登记：默认允许发动，并登记无效操作；若对象怪兽能够被破坏且仍与该效果关联，则追加登记破坏操作。
function c34717238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作将使eg（召唤成功时发动效果的怪兽）的发动无效，类别为CATEGORY_NEGATE。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记本次操作将破坏eg中的对象怪兽，类别为CATEGORY_DESTROY。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理阶段：先尝试无效那次怪兽效果的发动，若成功且对象怪兽仍与效果关联，则将其破坏。
function c34717238.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效发动成功，且发动的效果怪兽仍与效果保持关联时，才继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏eg中的那只怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
