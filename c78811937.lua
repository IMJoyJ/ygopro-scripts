--忍び寄る闇
-- 效果：
-- 把自己墓地2只暗属性怪兽从游戏中除外发动。从卡组把1只暗属性·4星怪兽加入手卡。
function c78811937.initial_effect(c)
	-- 把自己墓地2只暗属性怪兽从游戏中除外发动。从卡组把1只暗属性·4星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c78811937.cost)
	e1:SetTarget(c78811937.target)
	e1:SetOperation(c78811937.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的暗属性且可以作为发动代价除外的怪兽
function c78811937.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 发动代价（Cost）处理：检查并从自己墓地将2只暗属性怪兽表侧表示除外
function c78811937.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只满足条件的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78811937.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足过滤条件的暗属性怪兽
	local rg=Duel.SelectMatchingCard(tp,c78811937.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的怪兽作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中4星的暗属性且可以加入手牌的怪兽
function c78811937.filter(c)
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果的目标处理：检查卡组中是否存在满足条件的怪兽，并设置操作信息为将卡组的卡加入手牌
function c78811937.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的4星暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78811937.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）：从卡组选择1只4星暗属性怪兽加入手牌并给对方确认
function c78811937.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的4星暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c78811937.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
