--呪術抹消
-- 效果：
-- 丢弃2张手卡。使魔法卡的发动无效，并且将其破坏。确认对方的手卡及卡组，若存在与被破坏的魔法卡同名的卡，将其全部送去墓地。
function c29735721.initial_effect(c)
	-- 创建咒术抹消的发动效果，设置其为魔法卡发动时的效果，包含使发动无效、破坏和送去墓地的分类。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29735721.condition)
	e1:SetCost(c29735721.cost)
	e1:SetTarget(c29735721.target)
	e1:SetOperation(c29735721.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为魔法卡的发动且该发动可以被无效。
function c29735721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的连锁是否可以被无效。
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置咒术抹消的发动费用为丢弃2张手卡。
function c29735721.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若玩家受到解放之阿里阿德涅影响，则跳过费用检查。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 检查玩家手牌中是否存在至少2张可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 执行丢弃2张手卡的操作。
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 设置咒术抹消的发动目标，包括使发动无效和破坏魔法卡。
function c29735721.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏魔法卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行咒术抹消的效果处理，包括无效发动、破坏魔法卡、确认对方手卡和卡组并送去墓地。
function c29735721.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且魔法卡仍存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将魔法卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 中断当前效果处理，防止错时点。
	Duel.BreakEffect()
	-- 获取对方手卡和卡组中的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
	-- 确认对方手卡和卡组中的卡。
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(Card.IsCode,nil,re:GetHandler():GetCode())
	-- 将与被破坏魔法卡同名的卡送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 洗切对方手牌。
	Duel.ShuffleHand(1-tp)
	-- 洗切对方卡组。
	Duel.ShuffleDeck(1-tp)
end
