--創世竜
-- 效果：
-- 1回合1次，可以从手卡把1只龙族怪兽送去墓地，把自己墓地存在的1只龙族怪兽加入手卡。这张卡从场上送去墓地时，可以让自己墓地存在的龙族怪兽全部回到卡组。
function c31038159.initial_effect(c)
	-- 1回合1次，可以从手卡把1只龙族怪兽送去墓地，把自己墓地存在的1只龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31038159,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c31038159.thcost)
	e1:SetTarget(c31038159.thtg)
	e1:SetOperation(c31038159.thop)
	c:RegisterEffect(e1)
	-- 这张卡从场上送去墓地时，可以让自己墓地存在的龙族怪兽全部回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31038159,1))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c31038159.tdcon)
	e2:SetTarget(c31038159.tdtg)
	e2:SetOperation(c31038159.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在龙族且能作为代价送去墓地的怪兽。
function c31038159.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- 检查手卡中是否存在满足条件的龙族怪兽，若存在则将其丢弃作为效果的代价。
function c31038159.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31038159.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将满足条件的1张手卡丢弃作为效果的代价。
	Duel.DiscardHand(tp,c31038159.cfilter,1,1,REASON_COST)
end
-- 过滤函数，用于判断墓地中是否存在龙族且能加入手卡的怪兽。
function c31038159.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 设置效果的目标为满足条件的墓地中的龙族怪兽，并准备将该怪兽加入手卡。
function c31038159.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31038159.thfilter(chkc) end
	-- 检查墓地中是否存在满足条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c31038159.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张墓地中的龙族怪兽作为效果目标。
	local g=Duel.SelectTarget(tp,c31038159.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将选择的怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果，将目标怪兽加入手牌并确认对方看到该怪兽。
function c31038159.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽的加入手牌。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 判断该卡是否从场上送去墓地。
function c31038159.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断墓地中是否存在龙族且能返回卡组的怪兽。
function c31038159.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
-- 设置效果的目标为满足条件的墓地中的龙族怪兽，并准备将这些怪兽返回卡组。
function c31038159.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在满足条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31038159.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取所有满足条件的墓地中的龙族怪兽。
	local g=Duel.GetMatchingGroup(c31038159.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置效果操作信息，表示将选择的怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果，将所有满足条件的墓地中的龙族怪兽返回卡组并洗牌。
function c31038159.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的墓地中的龙族怪兽。
	local g=Duel.GetMatchingGroup(c31038159.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将所有满足条件的墓地中的龙族怪兽返回卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
