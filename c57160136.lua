--サイバネット・マイニング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把1张手卡送去墓地才能发动。从卡组把1只4星以下的电子界族怪兽加入手卡。
function c57160136.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把1张手卡送去墓地才能发动。从卡组把1只4星以下的电子界族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57160136+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c57160136.cost)
	e1:SetTarget(c57160136.target)
	e1:SetOperation(c57160136.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查并执行把1张手卡送去墓地的操作。
function c57160136.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在可以作为代价送去墓地的卡（排除这张卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡送去墓地作为发动代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤条件：等级4以下、电子界族且可以加入手卡的怪兽。
function c57160136.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 效果发动时的目标检测与操作信息设置。
function c57160136.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c57160136.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表明该效果包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽加入手卡并给对方确认。
function c57160136.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c57160136.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
