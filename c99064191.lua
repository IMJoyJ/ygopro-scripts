--エクシーズ・パニッシュ
-- 效果：
-- 1回合1次，自己场上有超量怪兽存在，5星以上的效果怪兽的效果发动时，可以通过丢弃1张手卡，那个效果无效并破坏。
function c99064191.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，自己场上有超量怪兽存在，5星以上的效果怪兽的效果发动时，可以通过丢弃1张手卡，那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99064191,0))  --"无效并破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetCondition(c99064191.condition)
	e2:SetCost(c99064191.cost)
	e2:SetTarget(c99064191.target)
	e2:SetOperation(c99064191.activate)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的超量怪兽
function c99064191.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查发动条件：自己场上有超量怪兽存在，且发动效果的是5星以上的效果怪兽，并且该效果可以被无效
function c99064191.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的超量怪兽
	return Duel.IsExistingMatchingCard(c99064191.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果、发动效果的怪兽等级是否在5星以上，以及该连锁效果是否可以被无效
		and re:IsActiveType(TYPE_EFFECT) and re:GetHandler():IsLevelAbove(5) and Duel.IsChainDisablable(ev)
end
-- 发动代价：丢弃1张手卡
function c99064191.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果的目标处理：设置无效与破坏的操作信息
function c99064191.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可以被破坏且仍存在于场上，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的实际处理：使效果无效并破坏该卡
function c99064191.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使效果无效，且该卡仍与该效果有关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
