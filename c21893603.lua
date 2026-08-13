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
-- 检索过滤函数：判定卡组中的卡是否为「星杯」怪兽且可以加入手卡。
function c21893603.thfilter(c)
	return c:IsSetCard(0xfd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动条件和处理信息：检查卡组是否存在符合条件的「星杯」怪兽，并设置回手牌/检索的操作信息。
function c21893603.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：仅在效果发动时确认卡组存在至少1只符合条件的「星杯」怪兽才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21893603.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计将1张卡从卡组加入手牌，用于连锁/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只「星杯」怪兽加入手牌，并让对方确认。
function c21893603.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「星杯」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21893603.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代价过滤函数：判定手牌或场上的怪兽是否可以作为代价送去墓地。
function c21893603.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 作为②效果的发动代价，从自己的手牌·场上选择1只怪兽送去墓地。
function c21893603.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价条件判定：确认存在至少1只可以作为代价的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21893603.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌·场上选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c21893603.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标判定：确认墓地的这张卡可以加入手牌，并设置回手牌操作信息。
function c21893603.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将这张卡从墓地加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果处理：如果这张卡仍与效果关联，则将其加入手牌。
function c21893603.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的这张卡以效果原因加入持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
