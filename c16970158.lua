--墓場からの呼び声
-- 效果：
-- 对方把「死者苏生」发动时才能发动。那张「死者苏生」的效果无效。
function c16970158.initial_effect(c)
	-- 对方把「死者苏生」发动时才能发动。那张「死者苏生」的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c16970158.condition)
	e1:SetTarget(c16970158.target)
	e1:SetOperation(c16970158.activate)
	c:RegisterEffect(e1)
end
-- 此函数为效果的发动条件判定，确认该连锁由对方玩家发动，且发动的是「死者苏生」的卡片发动效果，并且该连锁效果可以被无效。
function c16970158.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 依次判断：连锁发动者是否为对方玩家；该效果是否为卡片发动（即魔法·陷阱卡的发动）；发动效果的卡是否为「死者苏生」；该连锁效果是否具备可被无效的余地，四个条件全部满足时本卡才能发动。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(83764718) and Duel.IsChainDisablable(ev)
end
-- 此函数为效果发动时的目标处理：本卡不取对象，无选择卡牌步骤，直接允许发动（chk==0时返回true），并将本次操作信息登记为无效该连锁。
function c16970158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息，声明本连锁处理将执行“无效效果”类操作，处理对象为当前发动中的「死者苏生」及其相关连锁，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 此函数为效果处理时的操作：在连锁处理阶段直接无效对方发动的「死者苏生」的效果，使其效果不再适用。
function c16970158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁（即对方发动的「死者苏生」）的效果无效化，完成本卡的无效效果。
	Duel.NegateEffect(ev)
end
