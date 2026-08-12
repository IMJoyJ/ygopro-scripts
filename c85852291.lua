--打ち出の小槌
-- 效果：
-- ①：自己手卡任意数量回到卡组洗切。那之后，自己抽出回到卡组的数量。
function c85852291.initial_effect(c)
	-- ①：自己手卡任意数量回到卡组洗切。那之后，自己抽出回到卡组的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85852291.target)
	e1:SetOperation(c85852291.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检查，判断玩家是否能抽卡，以及手卡中是否存在可以回到卡组的卡
function c85852291.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否具有抽卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在至少1张可以回到卡组的卡（排除这张卡自身）
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息，表示此效果包含将手卡中的卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数，处理手卡送回卡组洗切并抽卡的效果
function c85852291.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手卡中任意数量可以回到卡组的卡
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 将选中的卡送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切玩家的卡组
	Duel.ShuffleDeck(p)
	-- 中断效果处理，使后续的抽卡与送回卡组不视为同时处理
	Duel.BreakEffect()
	-- 让玩家抽出与送回卡组的卡数量相同的卡
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
