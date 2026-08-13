--竜星の輝跡
-- 效果：
-- 「龙星的辉迹」在1回合只能发动1张。
-- ①：以自己墓地3只「龙星」怪兽为对象才能发动。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
function c17183908.initial_effect(c)
	-- 「龙星的辉迹」在1回合只能发动1张。①：以自己墓地3只「龙星」怪兽为对象才能发动。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
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
-- 定义效果筛选函数：从墓地选择满足是「龙星」怪兽且能够返回卡组的卡。
function c17183908.filter(c)
	return c:IsSetCard(0x9e) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 发动时的目标条件和发动判定：若指定过对象则确认该对象处于自己墓地且符合筛选条件；若在发动判定阶段，则检查自己能否抽2张且墓地存在至少3只符合条件的「龙星」怪兽。
function c17183908.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17183908.filter(chkc) end
	-- 发动条件判断：确认玩家可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 发动条件判断：确认自己墓地存在至少3只符合条件的「龙星」怪兽可以作为对象。
		and Duel.IsExistingTarget(c17183908.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3只符合条件的「龙星」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c17183908.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将选择的3张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息：自己将抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：取得连锁对象，若对象仍与效果相关且数量为3，则将它们返回卡组洗切；若实际返回卡组/额外卡组的数量为3，则中断效果处理并让自己抽2张。
function c17183908.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象卡以洗回卡组并洗切的方式，因效果送回持有者卡组。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才卡片操作实际被移动的卡组。
	local g=Duel.GetOperatedGroup()
	-- 若实际操作后的卡中有位于卡组的卡，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续抽卡视为不同时处理。
		Duel.BreakEffect()
		-- 自己抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
