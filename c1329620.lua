--壱世壊に澄み渡る残響
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，从自己手卡选1只怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以除外的1只自己的「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
function c1329620.initial_effect(c)
	-- 记录本卡效果文本中提到的「维萨斯-斯塔弗罗斯特」（卡号56099748），将该卡号加入关联卡名列表，用于相关字段/名称判定。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，从自己手卡选1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,1329620)
	e1:SetCondition(c1329620.condition)
	e1:SetTarget(c1329620.target)
	e1:SetOperation(c1329620.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡被效果送去墓地的场合，以除外的1只自己的「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,1329620)
	e2:SetCondition(c1329620.thcon)
	e2:SetTarget(c1329620.thtg)
	e2:SetOperation(c1329620.thop)
	c:RegisterEffect(e2)
end
-- 判定卡片是否为表侧表示且属于「珠泪哀歌族」怪兽（位于怪兽区域）或卡号为56099748（维萨斯-斯塔弗罗斯特），用于确认自己场上存在符合条件的怪兽。
function c1329620.actcfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- ①效果的发动条件：被连锁发动的是怪兽效果或魔法·陷阱卡的发动，且该连锁可以被无效；同时自己场上存在至少1张表侧表示且满足actcfilter的怪兽。
function c1329620.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果是否为怪兽效果或魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁能够被无效（Duel.IsChainNegatable）。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张满足actcfilter的卡（表侧表示的「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」）。
		and Duel.IsExistingMatchingCard(c1329620.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 用于选择手卡送去墓地的怪兽的过滤条件：必须是怪兽且能够被效果送去墓地。
function c1329620.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果发动时的合法性检查与操作信息登记：确认手卡有可送去墓地的怪兽；登记无效当前连锁、将那张卡返回卡组、以及从手卡送墓1只怪兽的操作信息。
function c1329620.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己手卡是否存在至少1只可送去墓地的怪兽（满足cfilter），以保证后续有卡可送。
	if chk==0 then return Duel.IsExistingMatchingCard(c1329620.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：将当前连锁的卡（eg）标记为要被无效的对象（CATEGORY_NEGATE），供规则检测使用。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的那张卡仍与连锁效果关联，则登记其返回持有者卡组的操作信息（CATEGORY_TODECK）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
	-- 设置操作信息：从自己手卡将1张卡送去墓地（CATEGORY_TOGRAVE），目标数量为1，目标位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：使那个发动无效；若成功且那张卡仍与效果关联，则将其返回持有者卡组并洗牌；之后从手卡选择1只怪兽送去墓地。
function c1329620.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 尝试无效连锁ev的发动，并检查被无效的卡是否仍与效果re关联（避免已离场导致后续无法弹回卡组）。
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将被无效的卡返回持有者卡组并洗牌；若成功返回且该卡位于卡组或额外卡组，则继续后续手卡送墓的处理。
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 向玩家显示选择提示“请选择要送去墓地的卡”（HINTMSG_TOGRAVE）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 由玩家从手卡选择1只满足cfilter的怪兽（怪兽且可送去墓地）。
			local g=Duel.SelectMatchingCard(tp,c1329620.cfilter,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				-- 中断当前效果处理，使后续的送墓处理成为独立时点，避免因连续处理造成错过时点。
				Duel.BreakEffect()
				-- 将选择的那只怪兽以效果原因（REASON_EFFECT）送去墓地。
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- ②效果的发动条件：这张卡因效果（REASON_EFFECT）被送去墓地时才能发动。
function c1329620.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②取对象目标的过滤条件：除外区表侧表示、自己的「珠泪哀歌族」怪兽，且能够加入手卡。
function c1329620.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand()
end
-- ②效果发动时的目标选择与操作信息登记：从除外区选择1只自己的表侧「珠泪哀歌族」怪兽为对象，并登记其加入手卡的操作信息。
function c1329620.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c1329620.thfilter(chkc) end
	-- 发动时（chk==0）检查除外区是否存在至少1只满足thfilter的自己怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c1329620.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示“请选择要加入手牌的卡”（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1只自己的表侧「珠泪哀歌族」怪兽作为效果对象（同时设定为连锁对象）。
	local g=Duel.SelectTarget(tp,c1329620.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选择的对象加入手卡（CATEGORY_TOHAND），用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若其仍与效果关联，则将其加入持有者手卡。
function c1329620.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的第一对象卡（即发动时选择的那只珠泪哀歌族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
