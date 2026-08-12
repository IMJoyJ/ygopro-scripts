--調和の宝札
-- 效果：
-- ①：从手卡丢弃1只攻击力1000以下的龙族调整才能发动。自己从卡组抽2张。
function c39701395.initial_effect(c)
	-- ①：从手卡丢弃1只攻击力1000以下的龙族调整才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39701395.cost)
	e1:SetTarget(c39701395.target)
	e1:SetOperation(c39701395.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手卡是否存在满足条件的龙族调整（攻击力1000以下且可丢弃）
function c39701395.filter(c)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(1000) and c:IsDiscardable()
end
-- 效果发动时的费用处理，丢弃1张满足条件的龙族调整
function c39701395.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃条件
	if chk==0 then return Duel.IsExistingMatchingCard(c39701395.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，丢弃1张符合条件的卡
	Duel.DiscardHand(tp,c39701395.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动目标，确定抽卡数量
function c39701395.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果，目标为当前玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数，执行抽卡操作
function c39701395.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
