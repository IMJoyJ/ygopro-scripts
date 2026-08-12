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
-- 过滤函数，用于检测卡组中是否存在名字带有「自然」的怪兽且能送去墓地的卡片。
function c24694698.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2a) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息。
function c24694698.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否在卡组中存在至少1张名字带有「自然」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24694698.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组选择1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作函数，用于选择并把卡送去墓地。
function c24694698.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张名字带有「自然」的怪兽。
	local g=Duel.SelectMatchingCard(tp,c24694698.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检测墓地中是否存在名字带有「自然」的怪兽且能返回卡组的卡片。
function c24694698.filter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息。
function c24694698.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24694698.filter(chkc) end
	-- 判断是否在墓地中存在至少2张名字带有「自然」的怪兽且玩家可以抽卡。
	if chk==0 then return Duel.IsExistingTarget(c24694698.filter,tp,LOCATION_GRAVE,0,2,nil) and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地中选择2张名字带有「自然」的怪兽。
	local g=Duel.SelectTarget(tp,c24694698.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息，表示将2张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置操作信息，表示将从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时执行的操作函数，用于选择并把卡返回卡组，再抽卡。
function c24694698.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将目标卡片组返回卡组并洗切卡组。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取之前一次卡片操作实际操作的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果返回卡组的卡中有进入卡组的，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
