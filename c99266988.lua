--混沌領域
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只光·暗属性怪兽送去墓地才能发动。和那只怪兽属性不同并是4～8星的1只不能通常召唤的光·暗属性怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外，从除外的自己怪兽之中以1只不能通常召唤的光·暗属性怪兽为对象才能发动。那只怪兽回到卡组最下面。那之后，自己从卡组抽1张。
function c99266988.initial_effect(c)
	-- ①：从手卡把1只光·暗属性怪兽送去墓地才能发动。和那只怪兽属性不同并是4～8星的1只不能通常召唤的光·暗属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99266988,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,99266988)
	e1:SetCost(c99266988.cost)
	e1:SetTarget(c99266988.target)
	e1:SetOperation(c99266988.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从除外的自己怪兽之中以1只不能通常召唤的光·暗属性怪兽为对象才能发动。那只怪兽回到卡组最下面。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99266988,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,99266989)
	-- 为②效果设置发动代价：将墓地的这张卡除外（使用aux.bfgcost简化函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99266988.tg)
	e2:SetOperation(c99266988.op)
	c:RegisterEffect(e2)
end
-- ①效果的代价判定/标记函数：在发动前先设标签100，表示代价支付条件已准备，实际送墓在target中执行；这样可以满足在同一个时机选择手牌怪兽作为代价。
function c99266988.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- ①效果选择手牌代价怪兽的过滤函数：要求该怪兽为光/暗属性且可作为代价送去墓地，并且卡组中存在与它属性不同且满足检索条件的怪兽，以保证代价成立。
function c99266988.tgfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
		-- 确认卡组中存在满足检索条件的光/暗属性怪兽（与手牌代价怪兽属性不同），作为代价成立的额外条件。
		and Duel.IsExistingMatchingCard(c99266988.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 检索目标的过滤条件：光/暗属性、与代价怪兽属性不同、等级4~8、不能通常召唤、且可以加入手牌。
function c99266988.thfilter(c,att)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsAttribute(att)
		and c:IsAbleToHand() and c:IsLevelAbove(4) and c:IsLevelBelow(8) and not c:IsSummonableCard()
end
-- ①效果的发动目标处理：检查发动条件；发动时选择手牌1只光/暗属性怪兽作为代价送去墓地，记录其属性用于后续检索，并设置检索的操作信息。
function c99266988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 发动条件检查：确认手牌中有1只可作为代价的光/暗属性怪兽，且卡组存在对应的检索目标。
		return Duel.IsExistingMatchingCard(c99266988.tgfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 发动时选择手牌1只光/暗属性怪兽（该选择将作为代价送去墓地）。
	local rg=Duel.SelectMatchingCard(tp,c99266988.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetAttribute())
	-- 将选择的手牌怪兽以代价形式送去墓地。
	Duel.SendtoGrave(rg,REASON_COST)
	-- 设置操作信息：本次效果包含从卡组把1张卡加入手牌的检索处理，用于星尘龙等卡的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：根据代价怪兽的属性，从卡组选择1张符合条件的怪兽加入手牌，并展示给对方确认。
function c99266988.activate(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	-- 显示选择提示“请选择要加入手牌的卡”，并用于选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足检索条件的光/暗属性怪兽（与代价怪兽属性不同、4~8星、不能通常召唤且可加入手牌）。
	local g=Duel.SelectMatchingCard(tp,c99266988.thfilter,tp,LOCATION_DECK,0,1,1,nil,att)
	local tc=g:GetFirst()
	if tc then
		-- 将选定怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果取对象目标的过滤条件：被除外的、表侧表示、光/暗属性、不能通常召唤、可以返回卡组。
function c99266988.tdfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsSummonableCard() and c:IsAbleToDeck()
end
-- ②效果的发动目标处理：检查对象与抽卡可行性；发动时选择1只除外的自己的不能通常召唤光/暗属性怪兽为对象，并设置返回卡组与抽卡的操作信息。
function c99266988.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c99266988.tdfilter(chkc) end
	-- 发动条件检查：存在1只除外的自己的符合条件的怪兽，且自己可以抽1张卡。
	if chk==0 then return Duel.IsExistingTarget(c99266988.tdfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	-- 显示选择提示“请选择要返回卡组的卡”，并用于选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1只除外的自己的不能通常召唤光/暗属性怪兽作为②效果的对象。
	local g=Duel.SelectTarget(tp,c99266988.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将对象怪兽返回卡组（操作对象为已选择的那1张卡）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：本次效果包含自己抽1张卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：将对象怪兽返回卡组最下面；若返回成功，则抽1张卡（通过BreakEffect使抽卡成为不同时处理）。
function c99266988.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回卡组最下面；确认返回成功且该卡位于卡组或额外卡组（避免因卡组顶替代等异常导致误判），才继续抽卡。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 中断当前效果，使后续抽卡效果视为不同时处理，以正确对应时点。
			Duel.BreakEffect()
			-- 自己从卡组抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
