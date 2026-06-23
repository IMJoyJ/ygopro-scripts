--パーソナル・スプーフィング
-- 效果：
-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中让1张「幻变骚灵」卡回到持有者卡组才能发动。从卡组把1只「幻变骚灵」怪兽加入手卡。
function c53936268.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中让1张「幻变骚灵」卡回到持有者卡组才能发动。从卡组把1只「幻变骚灵」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53936268,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c53936268.cost)
	e2:SetTarget(c53936268.target)
	e2:SetOperation(c53936268.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡或自己场上表侧表示的「幻变骚灵」卡
function c53936268.cfilter(c)
	return c:IsSetCard(0x103) and c:IsAbleToDeckAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 过滤条件：卡组中的「幻变骚灵」怪兽
function c53936268.thfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动代价：从手卡或自己场上表侧表示的卡中让1张「幻变骚灵」卡回到持有者卡组
function c53936268.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡或自己场上是否存在可作为代价返回卡组的「幻变骚灵」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53936268.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张手卡或自己场上表侧表示的「幻变骚灵」卡
	local g=Duel.SelectMatchingCard(tp,c53936268.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 如果选中的卡在手卡，则给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
	-- 将选中的卡作为代价送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果发动目标：检查卡组中是否存在可检索的怪兽，并设置操作信息
function c53936268.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可以加入手卡的「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53936268.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只「幻变骚灵」怪兽加入手卡
function c53936268.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「幻变骚灵」怪兽
	local g=Duel.SelectMatchingCard(tp,c53936268.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
