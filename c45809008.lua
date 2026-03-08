--デステニー・ドロー
-- 效果：
-- ①：从手卡丢弃1张「命运英雄」卡才能发动。自己从卡组抽2张。
function c45809008.initial_effect(c)
	-- 效果原文内容：①：从手卡丢弃1张「命运英雄」卡才能发动。自己从卡组抽2张。
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
-- 效果作用：定义过滤函数，用于检测手牌中是否包含「命运英雄」卡且可丢弃
function c45809008.filter(c)
	return c:IsSetCard(0xc008) and c:IsDiscardable()
end
-- 效果作用：检查玩家手牌中是否存在满足条件的「命运英雄」卡并将其丢弃作为发动代价
function c45809008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测手牌中是否存在至少1张「命运英雄」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45809008.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：从玩家手牌中丢弃1张满足条件的「命运英雄」卡
	Duel.DiscardHand(tp,c45809008.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：设置连锁的处理目标为当前玩家并设定抽卡数量为2
function c45809008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测当前玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置连锁的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁的目标参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 效果作用：设置连锁操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行抽卡操作，从卡组抽取指定数量的卡
function c45809008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让指定玩家从卡组抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
