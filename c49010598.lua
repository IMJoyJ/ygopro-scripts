--天罰
-- 效果：
-- 丢弃1张手卡发动。效果怪兽的效果的发动无效并破坏。
function c49010598.initial_effect(c)
	-- 丢弃1张手卡发动。效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c49010598.condition)
	e1:SetCost(c49010598.cost)
	e1:SetTarget(c49010598.target)
	e1:SetOperation(c49010598.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：仅当连锁中的效果为效果怪兽效果且该连锁可以被无效时，此卡才能发动。
function c49010598.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定被连锁的效果是否属于效果怪兽效果，以及该连锁是否可以被无效，两者同时满足时条件成立。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义发动代价：若存在改变丢弃手卡代价的效果则直接通过；否则需要检查并实际丢弃1张手卡作为代价。
function c49010598.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当己方受到“丢弃手卡代价变更”效果影响时，本卡的丢弃代价由该效果替代，直接判定代价满足。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 代价可行性检查：确认己方手牌中存在至少1张可以丢弃的卡，且不将发动中的本卡自身作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：由我方选择并丢弃1张手卡，丢弃原因记为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动时的目标与操作信息：不取对象，宣告无效被连锁的效果，并视情况宣告破坏其发动怪兽卡。
function c49010598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告要无效的对象为被连锁的效果，数量为1，用于配合无效发动的相关检测。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：宣告要破坏的对象为被连锁的发动怪兽卡，数量为1，用于配合破坏的相关检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理：先使被连锁的效果发动无效，再将其发动怪兽卡破坏。
function c49010598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效了该连锁，且被无效效果的发动卡仍与该效果保持关联，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效的发动怪兽卡（即eg对象）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
