--天罰
-- 效果：
-- 丢弃1张手卡发动。效果怪兽的效果的发动无效并破坏。
function c49010598.initial_effect(c)
	-- 效果发动时，将该卡注册为一个魔法卡效果，类型为发动效果，触发条件为连锁发动，需要支付丢弃手牌的代价，并设置对应的处理函数。
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
-- 当连锁发动的卡是怪兽卡且可以被无效时，该效果才能发动。
function c49010598.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁发动的卡是否为怪兽类型并且当前连锁可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付丢弃手牌的代价，若玩家受到解放之阿里阿德涅影响则无需支付。
function c49010598.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果玩家受到解放之阿里阿德涅效果影响，则直接返回成功，无需检查手牌。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 检查是否满足丢弃1张手牌的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手牌的操作，丢弃原因包括代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果处理时需要操作的信息，包括使连锁无效和可能破坏目标怪兽。
function c49010598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁中将要被无效的效果对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果目标怪兽可被破坏且与当前效果有关联，则将其加入操作信息中准备破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁无效并破坏对应的目标怪兽。
function c49010598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使连锁无效并且目标怪兽与效果相关联，则进行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏目标怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
