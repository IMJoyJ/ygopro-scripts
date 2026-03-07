--巌帯の美技－ゼノギタム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合，以「岩带的美技-磷钇矿吉他手」以外的自己墓地1只岩石族怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡在卡组最上面放置。
-- ②：这张卡从场上·墓地除外的场合才能发动。从卡组把1只岩石族怪兽送去墓地。
function c36187051.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，以「岩带的美技-磷钇矿吉他手」以外的自己墓地1只岩石族怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36187051,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36187051)
	e1:SetTarget(c36187051.thtg)
	e1:SetOperation(c36187051.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上·墓地除外的场合才能发动。从卡组把1只岩石族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36187051,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,36187052)
	e2:SetCondition(c36187051.tgcon)
	e2:SetTarget(c36187051.tgtg)
	e2:SetOperation(c36187051.tgop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地岩石族怪兽（不包括自己）
function c36187051.thfilter(c)
	return c:IsRace(RACE_ROCK) and not c:IsCode(36187051) and c:IsAbleToHand()
end
-- 设置效果处理时需要选择的墓地岩石族怪兽对象
function c36187051.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36187051.thfilter(chkc) end
	-- 检查是否满足选择墓地岩石族怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c36187051.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地岩石族怪兽作为对象
	local g=Duel.SelectTarget(tp,c36187051.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将对象怪兽送入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置将1张手卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 处理效果的执行操作，将对象怪兽送入手牌并可能将手卡送回卡组
function c36187051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽有效且已送入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 检查手牌中是否存在可送回卡组的卡
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 选择要送回卡组的手卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			-- 将选中的手卡送回卡组顶端
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 判断该卡是否从场上或墓地被除外
function c36187051.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 检索满足条件的卡组岩石族怪兽
function c36187051.tgfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
-- 设置效果处理时需要选择的卡组岩石族怪兽对象
function c36187051.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足选择卡组岩石族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c36187051.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1只岩石族怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的执行操作，从卡组选择1只岩石族怪兽送去墓地
function c36187051.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的卡组岩石族怪兽
	local g=Duel.SelectMatchingCard(tp,c36187051.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的岩石族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
