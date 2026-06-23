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
-- 过滤函数，用于筛选手牌中满足条件的水属性怪兽（可送入卡组）
function c22123627.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
-- 效果的发动条件判断，检查玩家是否可以抽3张卡且手牌中有至少2只水属性怪兽
function c22123627.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3)
		-- 检查手牌中是否存在至少2只水属性怪兽
		and Duel.IsExistingMatchingCard(c22123627.filter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息：将2张卡从手牌送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	-- 设置效果操作信息：自己从卡组抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果的处理函数，执行将符合条件的怪兽送回卡组并抽卡的操作
function c22123627.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家手牌中所有满足条件的水属性怪兽
	local g=Duel.GetMatchingGroup(c22123627.filter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=2 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,2,2,nil)
		-- 向对方确认玩家选择的卡
		Duel.ConfirmCards(1-p,sg)
		-- 将选择的卡送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 让玩家从卡组抽3张卡
		Duel.Draw(p,3,REASON_EFFECT)
	end
end
