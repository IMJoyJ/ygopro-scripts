--リロード
-- 效果：
-- 将自己的全部手卡放回卡组。那之后，抽与放回卡组的卡数量相同的卡。
function c22589918.initial_effect(c)
	-- 将自己的全部手卡放回卡组。那之后，抽与放回卡组的卡数量相同的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22589918.target)
	e1:SetOperation(c22589918.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的目标判定函数：在chk==0时检查发动条件，要求玩家能抽卡且手牌存在至少1张可返回卡组的卡。
function c22589918.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：当前玩家tp是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查发动条件：玩家tp手牌中存在至少1张可以返回卡组的卡（排除效果来源卡本身）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将当前连锁的对象玩家设置为tp，使此效果以玩家tp为对象。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：回卡组类别，表示预计将玩家tp手牌中的1张卡返回卡组（实际数量以处理时为准）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：抽卡类别，表示预计让玩家tp抽1张卡（实际数量在效果处理时根据回卡组数量决定）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数：获取对象玩家手牌，全部放回卡组并洗切，然后抽等量的卡。
function c22589918.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（发动时设置的tp），存入局部变量p。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对象玩家p手牌中的所有卡，构成卡组g。
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 将g中的所有卡以效果原因送回持有者的卡组，并标记需要洗牌（暂时置于卡组底部）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对象玩家p的卡组，将放回的卡随机排列。
	Duel.ShuffleDeck(p)
	-- 中断当前效果处理，使“放回卡组”与“抽卡”视为不同时处理，确保抽卡前卡组已正确洗切。
	Duel.BreakEffect()
	-- 让对象玩家p抽取与放回卡组数量（g:GetCount()）相同的卡。
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
