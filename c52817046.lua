--記憶抹消
-- 效果：
-- 对方手卡3张以下的场合才能发动。对方把手卡加入到卡组洗切。之后对方抽出和加入卡组的卡数量相同的卡。
function c52817046.initial_effect(c)
	-- 对方手卡3张以下的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c52817046.condition)
	e1:SetTarget(c52817046.target)
	e1:SetOperation(c52817046.activate)
	c:RegisterEffect(e1)
end
-- 检查对方手牌数量是否在1~3张之间
function c52817046.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方手牌数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	return ct>0 and ct<=3
end
-- 对方把手卡加入到卡组洗切。之后对方抽出和加入卡组的卡数量相同的卡。
function c52817046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp)
		-- 检查己方手牌中是否存在可送入卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置将对方手牌送入卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置对方抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行记忆抹消效果，将对方手牌送入卡组并洗切，然后抽取相同数量的卡
function c52817046.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家的手牌组
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 将目标玩家手牌全部送入卡组并洗切
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切目标玩家的卡组
	Duel.ShuffleDeck(p)
	-- 中断当前连锁处理
	Duel.BreakEffect()
	-- 让目标玩家抽取与送入卡组数量相同的卡
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
