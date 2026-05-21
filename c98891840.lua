--休息する剣闘獣
-- 效果：
-- 从自己手卡把2张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽3张卡。
function c98891840.initial_effect(c)
	-- 从自己手卡把2张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽3张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c98891840.target)
	e1:SetOperation(c98891840.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤手卡中名字带有「剑斗兽」且能回到卡组的卡
function c98891840.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 发动准备：检查玩家是否能抽3张卡，以及手卡中是否存在至少2张「剑斗兽」卡片
function c98891840.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3)
		-- 检查手卡中是否存在至少2张名字带有「剑斗兽」且能回到卡组的卡（排除这张卡自身）
		and Duel.IsExistingMatchingCard(c98891840.filter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：从手卡将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	-- 设置操作信息：玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理：从手卡选择2张「剑斗兽」卡片回到卡组，洗牌，然后抽3张卡
function c98891840.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取手卡中所有满足过滤条件的「剑斗兽」卡片
	local g=Duel.GetMatchingGroup(c98891840.filter,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=2 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,2,2,nil)
		-- 给对方玩家确认选中的卡片
		Duel.ConfirmCards(1-p,sg)
		-- 将选中的卡片送回卡组
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 玩家从卡组抽3张卡
		Duel.Draw(p,3,REASON_EFFECT)
	end
end
