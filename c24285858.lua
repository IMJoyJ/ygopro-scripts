--グラディアル・リターン
-- 效果：
-- 墓地存在的3张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽1张卡。
function c24285858.initial_effect(c)
	-- 效果原文内容：墓地存在的3张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24285858.target)
	e1:SetOperation(c24285858.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤器，用于筛选墓地里名字带有「剑斗兽」且可以送回卡组的卡片。
function c24285858.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 效果作用：设置效果目标，判断是否满足发动条件并选择目标卡片。
function c24285858.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24285858.filter(chkc) end
	-- 效果作用：检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果作用：检查玩家墓地是否存在至少3张符合条件的卡片。
		and Duel.IsExistingTarget(c24285858.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 效果作用：提示玩家选择要送回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择最多3张符合条件的墓地卡片作为效果对象。
	local g=Duel.SelectTarget(tp,c24285858.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 效果作用：设置效果操作信息，标记将要送回卡组的卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 效果作用：设置效果操作信息，标记将要抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：墓地存在的3张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽1张卡。
function c24285858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中已选定的目标卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 效果作用：将目标卡片组以效果原因送回卡组并洗牌。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：获取实际被操作的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 效果作用：如果送回卡组的卡片中有进入卡组的，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 效果作用：中断当前效果处理，使后续效果视为不同时处理。
		Duel.BreakEffect()
		-- 效果作用：让玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
