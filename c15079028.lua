--地久神－カルボン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把通常召唤的这张卡解放才能发动。从卡组把「地久神-碳素灵」以外的1只天使族·地属性怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的天使族怪兽被送去墓地的场合才能发动。这张卡回到卡组最上面。
function c15079028.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把通常召唤的这张卡解放才能发动。从卡组把「地久神-碳素灵」以外的1只天使族·地属性怪兽加入手卡。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的状态，自己场上的表侧表示的天使族怪兽被送去墓地的场合才能发动。这张卡回到卡组最上面。
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
-- 效果①的发动条件：判断这张卡是否是以通常召唤方式召唤（满足“把通常召唤的这张卡解放”的前提）。
function c15079028.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 效果①的代价处理：先确认这张卡可以被解放，再实际执行解放作为发动代价。
function c15079028.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为发动代价解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索过滤器：指定可检索的卡为「地久神-碳素灵」以外的天使族·地属性怪兽，并需要能加入手牌。
function c15079028.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(15079028) and c:IsAbleToHand()
end
-- 效果①发动目标设定：检查卡组是否有符合条件的怪兽，并设置检索加入手牌的操作信息。
function c15079028.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查卡组是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15079028.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统声明本效果包含“检索并加入手牌”的分类，操作信息为从卡组加入1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：从卡组选择符合条件的1只怪兽加入手牌，并向对方展示。
function c15079028.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，供玩家进行检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合检索过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c15079028.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认刚才加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的判定条件过滤器：被送去墓地的卡必须是天使族，且之前在自己场上表侧表示存在（用于判断“自己场上的表侧表示的天使族怪兽被送去墓地”）。
function c15079028.cfilter(c,tp)
	return c:IsRace(RACE_FAIRY)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- ②的发动条件：本次送去墓地的怪兽中存在自己场上的表侧表示天使族怪兽，且该触发事件不包括这张卡自身被送去墓地。
function c15079028.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15079028.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②的目标设定：确认这张卡能够回到卡组，并设置“回卡组”的操作信息。
function c15079028.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 向系统声明本效果为“回卡组”操作，处理对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②的处理：若这张卡仍与效果关联，则将其放回卡组最上面。
function c15079028.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者卡组最顶端。
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
