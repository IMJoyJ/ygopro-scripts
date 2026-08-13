--呪術抹消
-- 效果：
-- 丢弃2张手卡。使魔法卡的发动无效，并且将其破坏。确认对方的手卡及卡组，若存在与被破坏的魔法卡同名的卡，将其全部送去墓地。
function c29735721.initial_effect(c)
	-- 丢弃2张手卡。使魔法卡的发动无效，并且将其破坏。确认对方的手卡及卡组，若存在与被破坏的魔法卡同名的卡，将其全部送去墓地。
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
-- 发动条件判断：被连锁的效果必须是魔法卡的发动，且该发动可被无效。
function c29735721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果是否为魔法卡且属于魔法卡发动类型，同时该连锁可被无效。
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价函数：若存在改变丢弃代价的效果则直接允许发动；否则检查并执行丢弃2张手卡作为发动代价。
function c29735721.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若我方受到效果影响导致丢弃手卡的代价被改变，则跳过本卡的常规代价检查。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 检查我方手牌中是否存在至少2张可以丢弃的卡（不含本卡），以满足丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 从手牌选择2张卡丢弃，作为发动本卡的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 发动时的目标设定：登记将使魔法卡发动无效，并在可破坏且效果关联时登记破坏对象。
function c29735721.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁的魔法卡发动（eg）作为无效对象，分类为无效发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：将当前连锁的魔法卡（eg）作为破坏对象，分类为破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效并破坏发动中的魔法卡；之后确认对方手牌和卡组，将所有与被破坏魔法卡同名的卡送去墓地，并洗切对方手牌和卡组。
function c29735721.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该魔法卡的发动，且该魔法卡仍与效果保持关联，则执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效的魔法卡以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 中断当前效果链，使后续处理视为不同时处理，避免错过时点。
	Duel.BreakEffect()
	-- 获取对方手牌和卡组中的全部卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_DECK)
	-- 将对方手牌和卡组的卡片展示给我方玩家确认。
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(Card.IsCode,nil,re:GetHandler():GetCode())
	-- 将筛选出的与被破坏魔法卡同名的所有卡片送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 确认后洗切对方的手牌。
	Duel.ShuffleHand(1-tp)
	-- 确认后洗切对方的卡组。
	Duel.ShuffleDeck(1-tp)
end
