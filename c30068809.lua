--魔救の合縁
local s,id,o=GetID()
-- 初始化效果，注册两个效果：①通常发动效果；②墓地发动效果
function s.initial_effect(c)
	-- 通常发动效果：可以检索满足条件的卡加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 墓地发动效果：支付手牌一张卡送回卡组的代价，将自身送入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为魔救族怪兽且能送入手牌
function s.thfilter(c)
	return c:IsSetCard(0x140) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时点：检查是否有满足条件的卡存在于卡组中，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索卡组中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果：提示选择卡组中满足条件的卡并送入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断是否能作为送回卡组的代价
function s.cfilter(c)
	return c:IsAbleToDeckAsCost()
end
-- 发动效果：支付手牌一张卡送回卡组的代价，然后处理后续效果
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 显示选中的卡被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡送回卡组顶端并洗卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 设置墓地发动效果的目标信息：将自身送入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将自身送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地发动效果的处理函数：将自身送入手牌并确认对方查看
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,c)
	end
end
