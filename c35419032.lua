--侵略の侵喰感染
-- 效果：
-- 1回合1次，让自己手卡或者自己场上表侧表示存在的1只名字带有「入魔」的怪兽回到卡组才能发动。从自己卡组把1只名字带有「入魔」的怪兽加入手卡。
function c35419032.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 1回合1次，让自己手卡或者自己场上表侧表示存在的1只名字带有「入魔」的怪兽回到卡组才能发动。从自己卡组把1只名字带有「入魔」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35419032,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c35419032.cost)
	e2:SetTarget(c35419032.target)
	e2:SetOperation(c35419032.operation)
	c:RegisterEffect(e2)
end
-- 定义代价过滤条件：满足「入魔」字段、是怪兽卡、可作为代价返回卡组，且位于手牌或场上表侧表示的卡。
function c35419032.cfilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 定义检索过滤条件：满足「入魔」字段、是怪兽卡，且可以加入手卡的卡。
function c35419032.afilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 代价处理函数：选择1只满足cfilter的「入魔」怪兽，若入手牌则给对方确认，然后将其返回卡组并洗切作为发动代价。
function c35419032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己手牌或场上存在至少1只可作为代价返回卡组的「入魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35419032.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择要返回卡组的卡”的提示消息，引导玩家选择代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌或自己场上选择1只满足cfilter的「入魔」怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c35419032.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 若选择的代价卡来自手牌，则向对方展示该卡，以确认代价卡信息。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 将选择的代价卡返回持有者卡组并洗切（以代价原因），完成代价支付。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 目标设定函数：检查卡组存在可检索的「入魔」怪兽，并设置将卡加入手卡的操作信息。
function c35419032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己卡组存在至少1只满足afilter的「入魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35419032.afilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将处理从卡组把1只卡加入手卡（数量1，位置为卡组），供后续判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1只满足afilter的「入魔」怪兽加入手卡，并向对方展示。
function c35419032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示消息，引导玩家选择检索卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足afilter的「入魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,c35419032.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡，以确认检索到的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
