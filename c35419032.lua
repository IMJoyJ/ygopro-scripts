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
	-- 效果原文内容：1回合1次，让自己手卡或者自己场上表侧表示存在的1只名字带有「入魔」的怪兽回到卡组才能发动。
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
-- 规则层面作用：过滤满足条件的「入魔」怪兽，可回到卡组作为发动代价
function c35419032.cfilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 规则层面作用：过滤满足条件的「入魔」怪兽，可加入手牌
function c35419032.afilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：检查是否有满足条件的「入魔」怪兽，选择1只送回卡组作为发动代价
function c35419032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足发动条件，即是否有至少1张符合条件的「入魔」怪兽在手牌或场上
	if chk==0 then return Duel.IsExistingMatchingCard(c35419032.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 规则层面作用：提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：选择满足条件的1张「入魔」怪兽作为发动代价
	local g=Duel.SelectMatchingCard(tp,c35419032.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 规则层面作用：确认对方玩家看到被选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 规则层面作用：将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 规则层面作用：检查是否有满足条件的「入魔」怪兽，用于发动效果时检索
function c35419032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足效果发动条件，即卡组中是否有至少1张符合条件的「入魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35419032.afilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置效果处理信息，表示将从卡组检索1张「入魔」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：提示玩家选择要加入手牌的卡，并执行加入手牌操作
function c35419032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择满足条件的1张「入魔」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c35419032.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：确认对方玩家看到被选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
