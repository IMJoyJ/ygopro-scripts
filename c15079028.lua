--地久神－カルボン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把通常召唤的这张卡解放才能发动。从卡组把「地久神-碳素灵」以外的1只天使族·地属性怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的天使族怪兽被送去墓地的场合才能发动。这张卡回到卡组最上面。
function c15079028.initial_effect(c)
	-- ①：把通常召唤的这张卡解放才能发动。从卡组把「地久神-碳素灵」以外的1只天使族·地属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15079028,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,15079028)
	e1:SetCondition(c15079028.thcon)
	e1:SetCost(c15079028.thcost)
	e1:SetTarget(c15079028.thtg)
	e1:SetOperation(c15079028.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的天使族怪兽被送去墓地的场合才能发动。这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15079028,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,15079028)
	e2:SetCondition(c15079028.tdcon)
	e2:SetTarget(c15079028.tdtg)
	e2:SetOperation(c15079028.tdop)
	c:RegisterEffect(e2)
end
-- 效果发动时，检查此卡是否为通常召唤 summoned，只有通常召唤才能发动此效果。
function c15079028.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 效果发动时，检查此卡是否可以被解放，若可以则进行解放操作。
function c15079028.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为发动此效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索过滤器函数，用于筛选满足条件的天使族·地属性怪兽（不包括自身）。
function c15079028.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(15079028) and c:IsAbleToHand()
end
-- 设置此效果的发动目标，检查是否满足检索条件并设置操作信息。
function c15079028.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在满足条件的怪兽（天使族·地属性且非自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c15079028.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置此效果的处理信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示选择并检索符合条件的怪兽加入手牌。
function c15079028.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c15079028.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地触发效果的过滤器函数，用于判断是否为己方场上表侧表示的天使族怪兽被送去墓地。
function c15079028.cfilter(c,tp)
	return c:IsRace(RACE_FAIRY)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 效果发动时，检查是否有己方场上表侧表示的天使族怪兽被送去墓地。
function c15079028.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15079028.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置此墓地触发效果的目标，检查此卡是否可以返回卡组。
function c15079028.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置此效果的处理信息，表示将此卡返回卡组顶端。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡返回卡组顶端。
function c15079028.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送回卡组顶端。
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
