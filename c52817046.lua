--記憶抹消
-- 效果：
-- 对方手卡3张以下的场合才能发动。对方把手卡加入到卡组洗切。之后对方抽出和加入卡组的卡数量相同的卡。
function c52817046.initial_effect(c)
	-- 对方手卡3张以下的场合才能发动。对方把手卡加入到卡组洗切。之后对方抽出和加入卡组的卡数量相同的卡。
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
-- 效果发动条件：以tp视角统计对方手牌数为ct，要求ct大于0且小于等于3，即对方手牌为1～3张时本卡才能发动。
function c52817046.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计对方手牌数量并存入局部变量ct，供发动条件判断使用。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	return ct>0 and ct<=3
end
-- 发动合法性检查分支（chk==0）：判断对方是否能够抽卡，且存在可送回卡组的手牌，以此决定效果可否发动。
function c52817046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于发动合法性检查阶段（chk==0），先判断对方玩家（1-tp）是否可以进行抽卡，作为发动条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp)
		-- 同时检查是否至少存在1张可以返回卡组的卡（代码中实际以tp为视角筛选tp自己的手牌区域），作为发动条件之一。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将当前连锁的对象玩家设为对方（1-tp），之后可通过CHAININFO_TARGET_PLAYER取得该对象。
	Duel.SetTargetPlayer(1-tp)
	-- 设置回卡组的操作信息：登记本连锁将进行手牌返回卡组的处理，预计处理1张，目标位置为手牌（target_player按代码传tp）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置抽卡的操作信息：登记本连锁包含抽卡效果，预计从卡组抽1张卡，具体数量由效果处理时实际回卡组数决定（target_player按代码传tp）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：从连锁信息中取得对象玩家p，获取其手牌组g，全部送回卡组并洗切，然后按回卡组的数量抽卡。
function c52817046.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家p（即之前SetTargetPlayer设置的对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以p为视角获取其手牌区域的所有卡，组成卡片组g。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 将g中的手牌全部返回持有者卡组，并标记为需要洗切（SEQ_DECKSHUFFLE），原因记为REASON_EFFECT。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对象玩家p的卡组，使返回卡组的卡均匀混入卡组中。
	Duel.ShuffleDeck(p)
	-- 中断当前效果的处理时点，使后续的抽卡在另一个时点处理，避免与回卡组同时处理而错过时点。
	Duel.BreakEffect()
	-- 让对象玩家p抽取与刚才返回卡组数量相同（g:GetCount()）的卡，原因记为效果抽卡。
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
