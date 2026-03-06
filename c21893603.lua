--星杯の妖精リース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「星杯」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1只怪兽送去墓地才能发动。墓地的这张卡加入手卡。
function c21893603.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「星杯」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21893603,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21893603)
	e1:SetTarget(c21893603.thtg1)
	e1:SetOperation(c21893603.thop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1只怪兽送去墓地才能发动。墓地的这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21893603,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,21893604)
	e3:SetCost(c21893603.thcost2)
	e3:SetTarget(c21893603.thtg2)
	e3:SetOperation(c21893603.thop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「星杯」怪兽卡片组
function c21893603.thfilter(c)
	return c:IsSetCard(0xfd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用
function c21893603.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c21893603.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理
function c21893603.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c21893603.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认翻开的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 满足条件的怪兽卡片组
function c21893603.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理
function c21893603.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c21893603.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c21893603.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用
function c21893603.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理
function c21893603.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
