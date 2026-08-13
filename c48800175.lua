--ドラゴン・目覚めの旋律
-- 效果：
-- ①：丢弃1张手卡才能发动。把最多2只攻击力3000以上而守备力2500以下的龙族怪兽从卡组加入手卡。
function c48800175.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。把最多2只攻击力3000以上而守备力2500以下的龙族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c48800175.cost)
	e1:SetTarget(c48800175.target)
	e1:SetOperation(c48800175.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查己方手牌中是否存在可丢弃的卡，并执行丢弃1张手卡的代价。
function c48800175.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，确认己方手牌中是否存在至少1张可丢弃的卡（本卡自身除外），以满足丢弃手卡的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从己方手牌选择1张可丢弃的卡丢弃，丢弃原因同时视为代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索对象的筛选条件：卡必须为龙族、攻击力3000以上、守备力2500以下，且可以被加入手卡。
function c48800175.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttackAbove(3000) and c:IsDefenseBelow(2500) and c:IsAbleToHand()
end
-- 定义效果发动时的目标合法性检查：确认卡组中存在符合筛选条件的怪兽，并设置效果处理时“从卡组加入手卡”的操作信息。
function c48800175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段，确认己方卡组中是否存在至少1只满足筛选条件的龙族怪兽，作为效果可以发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c48800175.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果处理时会将1只符合条件的怪兽从卡组加入手卡，并标记检索/加入手卡的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理时的执行操作：从己方卡组选择1~2只符合条件的龙族怪兽加入手卡，并将检索结果展示给对方确认。
function c48800175.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家显示“请选择要加入手牌的卡”的提示信息，用于选择卡牌的玩家提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1~2只满足filter筛选条件的龙族怪兽（玩家可在1~2张之间选择），不取对象。
	local g=Duel.SelectMatchingCard(tp,c48800175.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，移送原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将本次检索加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
