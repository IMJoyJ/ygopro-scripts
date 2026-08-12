--光の援軍
-- 效果：
-- ①：从自己卡组上面把3张卡送去墓地才能发动。从卡组把1只4星以下的「光道」怪兽加入手卡。
function c94886282.initial_effect(c)
	-- ①：从自己卡组上面把3张卡送去墓地才能发动。从卡组把1只4星以下的「光道」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c94886282.cost)
	e1:SetTarget(c94886282.target)
	e1:SetOperation(c94886282.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数：检查并执行将卡组最上方的卡送去墓地
function c94886282.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能作为代价将卡组最上方的3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	-- 作为发动代价，将自己卡组最上方的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_COST)
end
-- 过滤条件：卡名含有「光道」且等级在4星以下且可以加入手牌的怪兽
function c94886282.filter(c)
	return c:IsSetCard(0x38) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 定义效果发动（Target）函数：检查卡组中是否存在符合条件的卡并设置操作信息
function c94886282.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94886282.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：将自己卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理（Operation）函数：从卡组检索符合条件的怪兽加入手牌
function c94886282.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从自己卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c94886282.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
