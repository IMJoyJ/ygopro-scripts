--竜星の輝跡
-- 效果：
-- 「龙星的辉迹」在1回合只能发动1张。
-- ①：以自己墓地3只「龙星」怪兽为对象才能发动。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
function c17183908.initial_effect(c)
	-- 创建效果，设置效果分类为返回卡组和抽卡，效果类型为发动，时点为自由时点，效果属性为取对象，发动次数限制为1次，设置效果目标函数和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,17183908+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c17183908.target)
	e1:SetOperation(c17183908.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选墓地中的龙星怪兽，满足种族为龙星、类型为怪兽且能返回卡组的条件
function c17183908.filter(c)
	return c:IsSetCard(0x9e) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果目标函数，判断是否满足发动条件，即自己墓地存在3只符合条件的龙星怪兽且自己可以抽2张卡
function c17183908.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17183908.filter(chkc) end
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己墓地是否存在3只符合条件的龙星怪兽
		and Duel.IsExistingTarget(c17183908.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家发送提示信息，提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3只符合条件的墓地龙星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c17183908.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置效果操作信息，指定将3张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置效果操作信息，指定自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数，处理效果的发动，包括将目标怪兽返回卡组、洗切卡组、抽卡等操作
function c17183908.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将目标怪兽以效果原因送回卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果返回卡组的卡片中有位于卡组的，则对玩家卡组进行洗切
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 让玩家以效果原因抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
