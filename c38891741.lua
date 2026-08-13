--神の摂理
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张卡从手卡丢弃才能发动。那个发动无效并破坏。
function c38891741.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张卡从手卡丢弃才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c38891741.condition)
	e1:SetCost(c38891741.cost)
	e1:SetTarget(c38891741.target)
	e1:SetOperation(c38891741.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：被连锁的效果必须是怪兽效果或魔法·陷阱卡的发动，且该连锁的发动可以被无效。
function c38891741.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否属于怪兽效果或魔法·陷阱卡发动，并且该连锁可以被无效。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 手卡丢弃代价的筛选函数：手卡必须与发动效果的种类相同（怪兽/魔法/陷阱）且可以作为代价丢弃。
function c38891741.cfilter(c,type)
	return c:IsType(type) and c:IsDiscardable()
end
-- 代价处理：若存在改变丢弃代价的效果则直接视为费用可支付；否则根据发动效果的种类确定需要丢弃的手卡类型，检测并丢弃1张同种类手卡作为代价。
function c38891741.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果玩家受到“丢弃手卡的代价变更”效果影响，则本卡不再实际丢弃手卡，费用视为满足（由替代代价效果处理）。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	local type=bit.band(re:GetActiveType(),0x7)
	-- 检查是否可以从手卡选择1张与发动效果种类相同且能丢弃的卡作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c38891741.cfilter,tp,LOCATION_HAND,0,1,nil,type) end
	-- 实际支付代价：让玩家从手卡选择1张同种类且可丢弃的卡，以代价和丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c38891741.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,type)
end
-- 发动时的目标处理：设定无效并破坏该连锁的操作信息；若发动卡可被破坏且与效果关联，则追加破坏操作信息。
function c38891741.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为“无效发动”，对象为当前连锁涉及的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为“破坏”，对象为当前连锁涉及的卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效该连锁的发动；若发动卡仍与效果关联，则将其破坏。
function c38891741.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，若无效失败则终止后续处理。
	if not Duel.NegateActivation(ev) then return end
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将仍与效果关联的发动卡以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
