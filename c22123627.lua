--強欲なウツボ
-- 效果：
-- ①：从手卡让2只水属性怪兽回到卡组洗切。那之后，自己从卡组抽3张。
function c22123627.initial_effect(c)
	-- ①：从手卡让2只水属性怪兽回到卡组洗切。那之后，自己从卡组抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22123627.target)
	e1:SetOperation(c22123627.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断一张卡是否为水属性怪兽，并且当前可以被送回卡组。
function c22123627.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
-- 效果发动时的合法性检查与发动信息登记：确认自己能否抽3张，且手牌中存在至少2只可回卡组的水属性怪兽；若满足则登记对象玩家及回卡组/抽卡的操作信息。
function c22123627.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动前检查（chk==0），先确认自己是否能够抽3张卡，若不能则效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3)
		-- 同时确认手牌中是否存在至少2只满足条件（水属性且可回卡组）的水属性怪兽，并且排除效果持有者自身。
		and Duel.IsExistingMatchingCard(c22123627.filter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 将当前连锁的对象玩家设置为发动者自己，用于后续回卡组与抽卡等处理。
	Duel.SetTargetPlayer(tp)
	-- 登记本次操作信息：从发动者手牌中选2张卡返回卡组（回卡组效果，对象位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	-- 登记本次操作信息：发动者抽3张卡（抽卡效果，数量为3）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理函数：获取对象玩家，从其手牌中选择2只水属性怪兽返回卡组洗切，然后该玩家抽3张卡。
function c22123627.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家（即执行回卡组和抽卡的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对象玩家手牌中所有满足条件（水属性且可回卡组）的怪兽，作为选择返回卡组的候选；若不足2张则本效果不处理。
	local g=Duel.GetMatchingGroup(c22123627.filter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=2 then
		-- 弹出选择提示，让玩家从候选中选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,2,2,nil)
		-- 将玩家选择的卡展示给对手确认。
		Duel.ConfirmCards(1-p,sg)
		-- 将选择的水属性怪兽返回持有者的卡组，使用SEQ_DECKSHUFFLE表示需要随后洗切卡组。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切对象玩家的卡组。
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理，使“回到卡组洗切”与“抽3张”分为两个独立时点，以符合原文“那之后”的先后顺序。
		Duel.BreakEffect()
		-- 对象玩家从卡组抽3张卡。
		Duel.Draw(p,3,REASON_EFFECT)
	end
end
