--スネーク・レイン
-- 效果：
-- ①：丢弃1张手卡才能发动。从卡组把4只爬虫类族怪兽送去墓地。
function c17189677.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把4只爬虫类族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17189677.cost)
	e1:SetTarget(c17189677.target)
	e1:SetOperation(c17189677.activate)
	c:RegisterEffect(e1)
end
-- 发动代价函数：确认并执行丢弃1张手卡作为发动代价。
function c17189677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中存在至少1张除蛇雨自身以外可丢弃的手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌挑选1张可丢弃的手卡以丢弃（当作代价）送入墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：卡是爬虫类族怪兽且可以送去墓地（作为送去墓地的对象）。
function c17189677.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 发动时点目标设定：确认卡组存在至少4只符合条件的爬虫类族怪兽，并设置本次效果将送去墓地的信息。
function c17189677.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少4只满足tgfilter（爬虫类族怪兽且能送去墓地）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c17189677.tgfilter,tp,LOCATION_DECK,0,4,nil) end
	-- 设置效果处理信息：把卡组的4张卡作为将要送去墓地的对象，用于连锁响应与效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,4,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选出4只符合条件的爬虫类族怪兽，送入墓地。
function c17189677.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的爬虫类族怪兽集合（数量不足4则不处理）。
	local g=Duel.GetMatchingGroup(c17189677.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=4 then
		-- 显示选择提示，让玩家从候选卡中选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,4,4,nil)
		-- 将已选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
