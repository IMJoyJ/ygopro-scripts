--エア・サーキュレーター
-- 效果：
-- ①：这张卡召唤成功时才能发动。让2张手卡回到卡组洗切。那之后，自己从卡组抽2张。
-- ②：这张卡被破坏的场合发动。自己从卡组抽1张。
function c7736719.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。让2张手卡回到卡组洗切。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7736719,0))  --"滤抽"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c7736719.target)
	e1:SetOperation(c7736719.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7736719,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetTarget(c7736719.drtg)
	e2:SetOperation(c7736719.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备与可行性检查：检查玩家是否能抽2张卡，且手牌中是否存在至少2张可以回到卡组的卡
function c7736719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 并且检查手牌中是否存在至少2张可以回到卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,nil) end
	-- 设置连锁信息：将手牌中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	-- 设置连锁信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①的效果处理：让2张手卡回到卡组洗切，那之后自己从卡组抽2张
function c7736719.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
	-- 如果手牌中可回卡组的卡不足2张，或者玩家无法抽卡，则不处理效果
	if g:GetCount()<2 or not Duel.IsPlayerCanDraw(tp) then return end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dg=g:Select(tp,2,2,nil)
	-- 将选中的2张手牌送回卡组
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切玩家的卡组
	Duel.ShuffleDeck(tp)
	-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
	Duel.BreakEffect()
	-- 玩家从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
-- 效果②的发动准备：设置抽卡的目标玩家、抽卡数量以及连锁操作信息
function c7736719.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：自己从卡组抽1张卡
function c7736719.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
