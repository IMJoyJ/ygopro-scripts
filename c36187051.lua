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
-- 效果1的过滤函数：筛选自己墓地中「岩带的美技-磷钇矿吉他手」以外、可以加入手卡的岩石族怪兽，作为取对象候选。
function c36187051.thfilter(c)
	return c:IsRace(RACE_ROCK) and not c:IsCode(36187051) and c:IsAbleToHand()
end
-- ①效果的发动时点判定和目标选择：确认自己墓地存在符合条件的岩石族怪兽；发动时选择1只为对象，并登记“对象加入手卡”及“自己1张手卡放置到卡组顶”的操作信息。
function c36187051.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36187051.thfilter(chkc) end
	-- 发动时点（非连锁处理时）检查自己墓地是否有1只以上符合条件的岩石族怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c36187051.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息，用于选择卡片的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的岩石族怪兽，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c36187051.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：将所选择的对象卡加入持有者手卡（用于效果发动后的处理判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 登记操作信息：之后将玩家自己1张手卡返回卡组顶端（对象数量1，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：将对象怪兽加入手卡；若成功加入手卡且仍在手牌，则洗切手牌，再选择1张手卡放到卡组最上面。
function c36187051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡（因为取对象时只选了1只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与效果关联（没有失去联系），且将其加入手卡的操作实际成功，并且该卡现在位于手牌中，才进行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 检查玩家手牌中是否存在1张以上可以返回卡组的卡（即是否还有手牌可作为代价）。
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
			-- 中断当前效果处理，使后续“将手卡放回卡组顶”的处理与前面的回手牌处理视为不同时处理（避免错过时点）。
			Duel.BreakEffect()
			-- 洗切玩家手牌（因为需要随机将一张手牌放回卡组顶，且重置洗牌检测状态）。
			Duel.ShuffleHand(tp)
			-- 给玩家显示“请选择要返回卡组的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 让玩家从手牌选择1张可以返回卡组的卡。
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			-- 将选择的手牌以效果原因返回持有者卡组最顶端。
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡是从场上或墓地除外的场合才能发动。
function c36187051.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果2的过滤函数：筛选卡组中岩石族且可以送去墓地的怪兽。
function c36187051.tgfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGrave()
end
-- ②效果的发动条件检查和操作信息登记：确认卡组中有1只以上符合条件的岩石族怪兽，并登记“从卡组把1只岩石族怪兽送去墓地”的操作信息。
function c36187051.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查卡组中是否存在1只以上符合条件的岩石族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36187051.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将卡组中的1只岩石族怪兽送去墓地（目标数量1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只岩石族怪兽送去墓地。
function c36187051.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只符合条件的岩石族怪兽。
	local g=Duel.SelectMatchingCard(tp,c36187051.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
