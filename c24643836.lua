--おジャマジック
-- 效果：
-- ①：这张卡从手卡·场上送去墓地的场合发动。从卡组把「扰乱·绿」「扰乱·黄」「扰乱·黑」各1只加入手卡。
function c24643836.initial_effect(c)
	-- 记录该卡牌效果关联的其他卡牌代码
	aux.AddCodeList(c,12482652,42941100,79335209)
	-- ①：这张卡从手卡·场上送去墓地的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24643836,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c24643836.thcon)
	e1:SetTarget(c24643836.thtg)
	e1:SetOperation(c24643836.thop)
	c:RegisterEffect(e1)
end
-- 判断该卡是否从手卡或场上离开
function c24643836.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 设置效果处理时的操作信息，指定将从卡组检索3张卡加入手牌
function c24643836.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将从卡组检索3张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
-- 定义过滤函数，用于筛选指定代码且可以加入手牌的卡
function c24643836.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果发动时执行的操作，从卡组检索指定的3张卡并加入手牌
function c24643836.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组检索第一张指定代码的卡
	local t1=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,12482652)
	if not t1 then return end
	-- 从卡组检索第二张指定代码的卡
	local t2=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,42941100)
	if not t2 then return end
	-- 从卡组检索第三张指定代码的卡
	local t3=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,79335209)
	if not t3 then return end
	local g=Group.FromCards(t1,t2,t3)
	-- 将检索到的卡送入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认送入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
