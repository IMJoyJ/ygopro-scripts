--創世竜
-- 效果：
-- 1回合1次，可以从手卡把1只龙族怪兽送去墓地，把自己墓地存在的1只龙族怪兽加入手卡。这张卡从场上送去墓地时，可以让自己墓地存在的龙族怪兽全部回到卡组。
function c31038159.initial_effect(c)
	-- ①：1回合1次，从手卡把1只龙族怪兽送去墓地，以自己墓地1只龙族怪兽为对象才能发动。那只龙族怪兽加入手卡。
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
	-- ②：这张卡从场上送去墓地时才能发动。自己墓地的龙族怪兽全部回到卡组。
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
-- 定义筛选函数：检查手卡中的卡是否满足种族为龙族且可作为代价送去墓地，用于①效果的代价检索。
function c31038159.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价函数：发动时确认手卡存在符合条件的龙族怪兽后，从手卡丢弃1只龙族怪兽作为发动代价。
function c31038159.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若不在发动阶段，则检查手卡中是否存在至少1只满足cfilter条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31038159.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：让玩家从手卡选择并丢弃1只满足条件的龙族怪兽，丢弃原因记为REASON_COST（作为代价）。
	Duel.DiscardHand(tp,c31038159.cfilter,1,1,REASON_COST)
end
-- 定义目标筛选函数：检查墓地中的龙族怪兽是否能够加入手卡，用于①效果选择对象。
function c31038159.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- ①效果的目标处理：指定对象时必须是自己墓地的龙族怪兽且能加入手卡；发动时确认存在对象后，选择1只作为效果对象，并设置回手牌的操作信息。
function c31038159.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31038159.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只满足thfilter条件的龙族怪兽可选为对象。
	if chk==0 then return Duel.IsExistingTarget(c31038159.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要加入手卡的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的龙族怪兽作为效果对象，并自动与该效果建立联系。
	local g=Duel.SelectTarget(tp,c31038159.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次连锁将把1张卡加入手牌（CATEGORY_TOHAND），用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若仍与效果关联则将其加入手牌，并向对方展示那张卡。
function c31038159.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即被选为目标的墓地龙族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送去其持有者的手卡（REASON_EFFECT，效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张怪兽卡的卡面信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果的发动条件：这张卡在从场上（主要怪兽区/魔法陷阱区）被送去墓地时才能发动。
function c31038159.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义筛选函数：检查墓地中的龙族怪兽是否能够返回卡组，用于②效果。
function c31038159.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
-- ②效果的目标处理：确认墓地存在至少1只符合条件的龙族怪兽，并取得全部满足条件的龙族怪兽，设置回卡组的操作信息。
function c31038159.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己墓地存在至少1只满足tdfilter条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c31038159.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己墓地中所有满足条件的龙族怪兽（不取对象，处理时全选）。
	local g=Duel.GetMatchingGroup(c31038159.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置操作信息：本次连锁将把卡组送入卡组（CATEGORY_TODECK），用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：将自己墓地中所有符合条件的龙族怪兽全部返回卡组，并洗牌。
function c31038159.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得自己墓地中所有满足条件的龙族怪兽（效果处理时确定）。
	local g=Duel.GetMatchingGroup(c31038159.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将取得的怪兽全部送回持有者卡组，并洗切卡组（弹回卡组并洗牌，REASON_EFFECT）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
