--速攻魔力増幅器
-- 效果：
-- 从自己墓地选择「速攻魔力增幅器」以外的1张速攻魔法卡回到卡组。此外，场上的这张卡被对方破坏送去墓地的场合，可以从卡组把「速攻魔力增幅器」以外的1张速攻魔法卡加入手卡。
function c45869829.initial_effect(c)
	-- 从自己墓地选择「速攻魔力增幅器」以外的1张速攻魔法卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45869829.target)
	e1:SetOperation(c45869829.activate)
	c:RegisterEffect(e1)
	-- 场上的这张卡被对方破坏送去墓地的场合，可以从卡组把「速攻魔力增幅器」以外的1张速攻魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45869829,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c45869829.thcon)
	e2:SetTarget(c45869829.thtg)
	e2:SetOperation(c45869829.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为速攻魔法卡且不是自身且可以送入卡组。
function c45869829.filter(c)
	return c:IsType(TYPE_QUICKPLAY) and not c:IsCode(45869829) and c:IsAbleToDeck()
end
-- 设置效果目标，选择满足条件的墓地速攻魔法卡作为对象。
function c45869829.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45869829.filter(chkc) end
	-- 检查是否满足选择目标的条件，即是否存在满足条件的墓地速攻魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c45869829.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地速攻魔法卡作为目标。
	local g=Duel.SelectTarget(tp,c45869829.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将目标卡送入卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数，将选定的卡送入卡组。
function c45869829.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 触发条件判断，确认该卡是被对方破坏送入墓地的。
function c45869829.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤函数，用于判断是否为速攻魔法卡且不是自身且可以加入手牌。
function c45869829.thfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and not c:IsCode(45869829) and c:IsAbleToHand()
end
-- 设置检索效果的目标，检查卡组中是否存在满足条件的速攻魔法卡。
function c45869829.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索目标的条件，即是否存在满足条件的卡组速攻魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c45869829.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，指定将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理函数，从卡组选择一张速攻魔法卡加入手牌。
function c45869829.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,c45869829.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
