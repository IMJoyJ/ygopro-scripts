--デステニー・ドロー
-- 效果：
-- ①：从手卡丢弃1张「命运英雄」卡才能发动。自己从卡组抽2张。
function c45809008.initial_effect(c)
	-- ①：从手卡丢弃1张「命运英雄」卡才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c45809008.cost)
	e1:SetTarget(c45809008.target)
	e1:SetOperation(c45809008.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：手卡中存在满足“命运英雄”字段且可以被丢弃的卡。
function c45809008.filter(c)
	return c:IsSetCard(0xc008) and c:IsDiscardable()
end
-- 代价函数：先检查是否满足代价条件，再执行丢弃手卡中1张“命运英雄”卡作为发动代价。
function c45809008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在至少1张满足筛选条件的“命运英雄”卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c45809008.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：玩家tp从手卡选择1张满足条件的“命运英雄”卡，以代价并丢弃的原因送去墓地。
	Duel.DiscardHand(tp,c45809008.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标设定函数：效果发动时检查玩家能否抽卡，并设置效果的目标玩家为tp、抽卡数量为2，同时登记操作信息。
function c45809008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：确认玩家tp是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设置为tp，表示抽卡效果作用于tp。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2，表示抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本连锁处理时会进行抽卡，目标玩家为tp，预计抽2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：执行抽卡操作，从连锁信息中获取目标玩家和抽卡数量后让对应玩家抽卡。
function c45809008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和抽卡数量，分别存入变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 玩家p抽取d张卡，抽卡原因为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
