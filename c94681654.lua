--フェザー・ウィンド・アタック
-- 效果：
-- 让自己场上表侧表示存在的1只名字带有「黑羽」的怪兽回到卡组发动。从自己卡组把1只名字带有「黑羽」的怪兽加入手卡。
function c94681654.initial_effect(c)
	-- 让自己场上表侧表示存在的1只名字带有「黑羽」的怪兽回到卡组发动。从自己卡组把1只名字带有「黑羽」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c94681654.cost)
	e1:SetTarget(c94681654.target)
	e1:SetOperation(c94681654.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且能作为代价返回卡组的「黑羽」怪兽
function c94681654.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsAbleToDeckAsCost()
end
-- 发动代价：选择自己场上1只表侧表示的「黑羽」怪兽返回卡组
function c94681654.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价返回卡组的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94681654.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只表侧表示的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c94681654.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为代价返回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「黑羽」怪兽
function c94681654.filter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的目标：检查卡组中是否存在「黑羽」怪兽，并设置操作信息
function c94681654.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94681654.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只「黑羽」怪兽加入手牌
function c94681654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c94681654.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
