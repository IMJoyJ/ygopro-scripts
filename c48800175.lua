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
-- 检查是否满足丢弃手卡的代价条件
function c48800175.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选符合条件的龙族怪兽（攻击力3000以上，守备力2500以下，且能加入手牌）
function c48800175.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttackAbove(3000) and c:IsDefenseBelow(2500) and c:IsAbleToHand()
end
-- 设置连锁处理的目标信息，准备从卡组检索满足条件的怪兽
function c48800175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48800175.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果的主要处理流程，选择并把符合条件的怪兽加入手牌
function c48800175.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择最多2张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c48800175.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽的卡片信息
		Duel.ConfirmCards(1-tp,g)
	end
end
