--ナチュル・マロン
-- 效果：
-- 这张卡召唤成功时，可以从自己卡组把1只名字带有「自然」的怪兽送去墓地。此外，1回合1次，可以选择自己墓地存在的2只名字带有「自然」的怪兽回到卡组，从自己卡组抽1张卡。
function c24694698.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组把1只名字带有「自然」的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24694698,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c24694698.target)
	e1:SetOperation(c24694698.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以选择自己墓地存在的2只名字带有「自然」的怪兽回到卡组，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24694698,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c24694698.drtg)
	e2:SetOperation(c24694698.drop)
	c:RegisterEffect(e2)
end
-- 定义第一个效果的过滤函数：筛选卡组中满足条件的自然怪兽，要求为怪兽卡、卡名带有「自然」且可以被送去墓地。
function c24694698.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2a) and c:IsAbleToGrave()
end
-- 定义第一个效果的发动条件与操作信息设置：召唤成功时，若卡组存在可送墓的自然怪兽则允许发动，并预设置送去墓地的效果信息。
function c24694698.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张符合条件的自然怪兽（满足tgfilter），作为发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c24694698.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 预设置效果处理信息：从卡组把1张卡送去墓地，数量为1，对象不确定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义第一个效果的处理：从卡组选择1张符合条件的自然怪兽并送去墓地。
function c24694698.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从卡组选择1张符合条件的自然怪兽（tgfilter）。
	local g=Duel.SelectMatchingCard(tp,c24694698.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义第二个效果的过滤函数：筛选墓地里满足条件的自然怪兽，要求为怪兽卡、卡名带有「自然」且可以返回卡组。
function c24694698.filter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 定义第二个效果的发动条件、取对象选择和操作信息设置：选择墓地2张自然怪兽返回卡组，然后抽1张卡。
function c24694698.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24694698.filter(chkc) end
	-- 检查发动条件：墓地存在至少2张符合条件的自然怪兽可以作为对象，且玩家可以抽1张卡。
	if chk==0 then return Duel.IsExistingTarget(c24694698.filter,tp,LOCATION_GRAVE,0,2,nil) and Duel.IsPlayerCanDraw(tp,1) end
	-- 显示“请选择要返回卡组的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地选择2张符合条件的自然怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24694698.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：将2张对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置操作信息：抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义第二个效果的处理：对象卡返回卡组，若两张都正确返回则抽1张卡。
function c24694698.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中这张卡发动时选择的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将对象卡返回持有者卡组（以洗牌方式，置于卡组底端作为临时标记，随后洗切）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际被操作的卡组。
	local g=Duel.GetOperatedGroup()
	-- 如果实际被操作的卡组中有卡进入了卡组，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果处理，使后续的抽卡视为不同时处理，避免产生错误的时点。
		Duel.BreakEffect()
		-- 使玩家抽1张卡，触发原因为效果。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
