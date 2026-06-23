--トレード・イン
-- 效果：
-- ①：从手卡丢弃1只8星怪兽才能发动。自己抽2张。
function c38120068.initial_effect(c)
	-- ①：从手卡丢弃1只8星怪兽才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38120068.cost)
	e1:SetTarget(c38120068.target)
	e1:SetOperation(c38120068.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测手卡中是否包含满足条件的8星怪兽
function c38120068.filter(c)
	return c:IsLevel(8) and c:IsDiscardable()
end
-- 检查玩家是否满足丢弃1只8星怪兽的发动条件并执行丢弃操作
function c38120068.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家手卡中是否存在至少1只8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38120068.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中丢弃1只满足条件的8星怪兽作为发动代价
	Duel.DiscardHand(tp,c38120068.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果发动时的目标玩家和抽卡数量
function c38120068.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置连锁效果的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果发动时的抽卡操作
function c38120068.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
