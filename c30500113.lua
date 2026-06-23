--RR－リターン
-- 效果：
-- 「急袭猛禽-归来」的②的效果1回合只能使用1次。
-- ①：自己场上的「急袭猛禽」怪兽被战斗破坏的场合，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己场上的「急袭猛禽」怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从卡组把1张「急袭猛禽」卡加入手卡。
function c30500113.initial_effect(c)
	-- ①：自己场上的「急袭猛禽」怪兽被战斗破坏的场合，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c30500113.condition)
	e1:SetTarget(c30500113.target)
	e1:SetOperation(c30500113.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「急袭猛禽」怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从卡组把1张「急袭猛禽」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,30500113)
	e2:SetCondition(c30500113.thcon)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30500113.thtg)
	e2:SetOperation(c30500113.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：满足条件的怪兽为急袭猛禽族且之前在自己的控制下
function c30500113.cfilter1(c,tp)
	return c:IsSetCard(0xba) and c:IsPreviousControler(tp)
end
-- 判断是否满足条件：场上的怪兽中是否存在满足cfilter1条件的怪兽
function c30500113.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30500113.cfilter1,1,nil,tp)
end
-- 过滤条件：满足条件的卡为急袭猛禽族怪兽且能加入手牌
function c30500113.filter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标：选择满足条件的墓地1只怪兽作为效果对象
function c30500113.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30500113.filter(chkc) end
	-- 检查是否满足条件：场上是否存在满足filter条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c30500113.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c30500113.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选择的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选择的怪兽加入手牌
function c30500113.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：满足条件的怪兽为急袭猛禽族且因效果破坏、之前在自己的控制下、在主要怪兽区正面表示
function c30500113.cfilter2(c,tp)
	return c:IsSetCard(0xba) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否满足条件：破坏的怪兽中是否存在满足cfilter2条件的怪兽且不包含自己
function c30500113.thcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	return eg:IsExists(c30500113.cfilter2,1,nil,tp)
end
-- 过滤条件：满足条件的卡为急袭猛禽族且能加入手牌
function c30500113.thfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- 设置效果目标：从卡组选择1张急袭猛禽卡加入手牌
function c30500113.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组中是否存在满足thfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30500113.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组选择1张急袭猛禽卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张急袭猛禽卡加入手牌并确认给对方看
function c30500113.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c30500113.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
