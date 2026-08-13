--トラップ・ジャマー
-- 效果：
-- 战斗阶段中才能发动。对方发动的陷阱卡的发动无效并破坏。
function c19252988.initial_effect(c)
	-- 战斗阶段中才能发动。对方发动的陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c19252988.condition)
	e1:SetTarget(c19252988.target)
	e1:SetOperation(c19252988.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：当前为战斗阶段，且对方发动的是陷阱卡的发动效果，并且该连锁能够被无效，才满足发动条件。
function c19252988.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph，用于后续判断是否为战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=0x08 and ph<=0x20 and tp~=ep and re:IsActiveType(TYPE_TRAP)
		-- 进一步确认对方发动的陷阱卡效果属于发动类型（ACTIVATE），且该连锁可以被无效化。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 发动时的目标处理：无选择目标，先登记无效发动的操作信息；若对方那张陷阱卡可被破坏且与效果关联，则追加登记破坏的操作信息。
function c19252988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁中的对方陷阱卡（eg）登记为无效发动的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 将同一张对方陷阱卡（eg）登记为破坏的对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：尝试无效对方陷阱卡的发动，若成功且该卡仍与本次效果关联，则将其破坏。
function c19252988.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效发动的处理，并检查对方那张陷阱卡是否仍与本次发动的效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）将连锁中的那张对方陷阱卡（eg）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
