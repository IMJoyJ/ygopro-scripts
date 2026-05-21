--角笛砕き
-- 效果：
-- 要让怪兽的召唤·特殊召唤无效的怪兽的效果·陷阱卡发动时才能发动。那个发动无效并破坏。
function c93396832.initial_effect(c)
	-- 要让怪兽的召唤·特殊召唤无效的怪兽的效果·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c93396832.condition)
	e1:SetTarget(c93396832.target)
	e1:SetOperation(c93396832.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：必须是怪兽效果或陷阱卡的发动，且该效果包含无效召唤的效果，并且该连锁的发动可以被无效
function c93396832.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or (re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))
		-- 检查该效果是否含有“无效召唤”的效果分类，且该连锁的发动可以被无效
		and re:IsHasCategory(CATEGORY_DISABLE_SUMMON) and Duel.IsChainNegatable(ev)
end
-- 设置效果处理的预估操作信息，包括“使发动无效”和“破坏”
function c93396832.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理包含“使该连锁的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可被破坏且与该效果有关联，则设置操作信息，表示该效果的处理包含“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使该连锁的发动无效并破坏
function c93396832.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且发动效果的卡仍与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动该效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
