--ツバメ返し
-- 效果：
-- 特殊召唤成功时发动的效果怪兽的效果的发动无效并破坏。
function c10651797.initial_effect(c)
	-- 特殊召唤成功时发动的效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c10651797.condition)
	e1:SetTarget(c10651797.target)
	e1:SetOperation(c10651797.activate)
	c:RegisterEffect(e1)
end
-- 该效果为反击陷阱，仅在对方发动特殊召唤成功时发动的怪兽效果且该发动可被无效时才能发动。
function c10651797.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断正在发动的效果是否为怪兽效果、其发动时机是否为特殊召唤成功时，以及该连锁是否能够被无效。
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SPSUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 发动时确认效果合法后，设定将那次效果发动无效的操作信息；若那只发动效果的怪兽能够被破坏且仍与效果相关，则同时设定破坏该怪兽的操作信息。
function c10651797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁的发动将被无效，对象为发动效果的那只怪兽（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若条件满足，将那只发动效果的怪兽（eg）作为要被破坏的对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时执行：先无效那次效果的发动，若成功且那只怪兽仍与效果相关，则将其破坏。
function c10651797.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果发动是否被成功无效，以及发动效果的那只怪兽是否仍然与这个被无效的效果保持关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将eg中那只发动效果的怪兽以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
