--深海のアリア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只水属性怪兽除外才能发动。从卡组把1只4星以下的海龙族怪兽加入手卡。
function c72060415.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地把1只水属性怪兽除外才能发动。从卡组把1只4星以下的海龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,72060415+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c72060415.cost)
	e1:SetTarget(c72060415.target)
	e1:SetOperation(c72060415.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为代价除外的水属性怪兽
function c72060415.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价处理：从自己墓地把1只水属性怪兽除外
function c72060415.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以作为代价除外的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72060415.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c72060415.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可以加入手卡的4星以下的海龙族怪兽
function c72060415.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置
function c72060415.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手卡的4星以下的海龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72060415.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只4星以下的海龙族怪兽加入手卡
function c72060415.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的4星以下的海龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c72060415.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
