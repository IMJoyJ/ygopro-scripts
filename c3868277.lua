--TGX3－DX2
-- 效果：
-- 选择自己墓地存在的3只名字带有「科技属」的怪兽发动。选择的怪兽加入卡组洗切。那之后，从自己卡组抽2张卡。
function c3868277.initial_effect(c)
	-- 效果原文内容：选择自己墓地存在的3只名字带有「科技属」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3868277.target)
	e1:SetOperation(c3868277.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤器，用于筛选墓地中的「科技属」怪兽
function c3868277.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x27) and c:IsAbleToDeck()
end
-- 效果作用：设置效果目标，检查是否满足发动条件
function c3868277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3868277.filter(chkc) end
	-- 效果作用：检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 效果作用：检查玩家墓地是否存在3只符合条件的怪兽
		and Duel.IsExistingTarget(c3868277.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 效果作用：提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择3只符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c3868277.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 效果作用：设置效果操作信息，指定将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 效果作用：设置效果操作信息，指定从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果原文内容：选择的怪兽加入卡组洗切。那之后，从自己卡组抽2张卡。
function c3868277.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 效果作用：将选择的怪兽送回卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：获取实际被操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 效果作用：若送回卡组的怪兽存在于卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 效果作用：中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
