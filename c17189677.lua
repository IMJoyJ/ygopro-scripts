--スネーク・レイン
-- 效果：
-- ①：丢弃1张手卡才能发动。从卡组把4只爬虫类族怪兽送去墓地。
function c17189677.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡才能发动。从卡组把4只爬虫类族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17189677.cost)
	e1:SetTarget(c17189677.target)
	e1:SetOperation(c17189677.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足丢弃手卡的代价条件并执行丢弃操作
function c17189677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：执行丢弃1张手牌的操作，原因包括代价和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义筛选爬虫类族怪兽的过滤函数
function c17189677.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果作用：检查卡组中是否存在至少4只满足条件的怪兽并设置操作信息
function c17189677.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断卡组中是否存在至少4只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17189677.tgfilter,tp,LOCATION_DECK,0,4,nil) end
	-- 效果作用：设置连锁操作信息，指定将4张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,4,tp,LOCATION_DECK)
end
-- 效果作用：检索卡组中满足条件的怪兽并选择其中4只送去墓地
function c17189677.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取卡组中所有满足条件的怪兽组成卡片组
	local g=Duel.GetMatchingGroup(c17189677.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=4 then
		-- 效果作用：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,4,4,nil)
		-- 效果作用：将选中的怪兽以效果原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
