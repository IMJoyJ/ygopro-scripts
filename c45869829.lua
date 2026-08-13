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
	-- 此外，场上的这张卡被对方破坏送去墓地的场合，可以从卡组把「速攻魔力增幅器」以外的1张速攻魔法卡加入手卡。
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
-- 过滤条件：必须是速攻魔法卡、卡名不是「速攻魔力增幅器」、且可以被送回卡组。
function c45869829.filter(c)
	return c:IsType(TYPE_QUICKPLAY) and not c:IsCode(45869829) and c:IsAbleToDeck()
end
-- 发动时的目标选择处理：从自己墓地选择1张符合条件的速攻魔法卡作为对象，并设置将卡返回卡组的操作信息。
function c45869829.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45869829.filter(chkc) end
	-- 合法性检查：若在效果发动前的检查阶段，确认自己墓地是否存在至少1张符合条件的速攻魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45869829.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择提示，要求选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的速攻魔法卡，并将其设为这次连锁的对象。
	local g=Duel.SelectTarget(tp,c45869829.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本连锁效果处理时会将1张卡返回卡组，对象为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将发动时选择的对象卡返回持有者卡组并洗牌。
function c45869829.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时该连锁对应的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去持有者卡组并洗牌（SEQ_DECKSHUFFLE 表示返回卡组后洗牌）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 第二效果的发动条件：这张卡被对方破坏并送去墓地，且破坏前是在自己场上由自己控制。
function c45869829.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 检索过滤条件：必须是速攻魔法卡、卡名不是「速攻魔力增幅器」、且可以加入手卡。
function c45869829.thfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and not c:IsCode(45869829) and c:IsAbleToHand()
end
-- 检索效果的目标处理：检查卡组是否存在符合条件的速攻魔法卡，并设置从卡组加入手卡的操作信息。
function c45869829.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认卡组是否存在至少1张符合条件的速攻魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c45869829.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理时会从卡组把1张卡加入手卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选择1张符合条件的速攻魔法卡加入手卡，并让对方确认。
function c45869829.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，要求选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,c45869829.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
