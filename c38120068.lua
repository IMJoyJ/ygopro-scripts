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
-- 筛选满足发动代价的卡：等级为8星且能够被丢弃的手卡。
function c38120068.filter(c)
	return c:IsLevel(8) and c:IsDiscardable()
end
-- 发动代价处理：检查并实际从手卡丢弃1只8星怪兽作为COST。
function c38120068.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡中存在1只8星且可丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c38120068.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择1只8星怪兽丢弃，丢弃原因记为COST+DISCARD。
	Duel.DiscardHand(tp,c38120068.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的目标设定：将自己设为抽卡玩家，抽卡数设为2，并登记抽卡操作信息。
function c38120068.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己当前可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设为自己，决定后续抽牌者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设为2，决定后续抽牌数量。
	Duel.SetTargetParam(2)
	-- 登记处理时要执行的抽卡操作信息：分类为抽卡，目标为自己，张数为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段实际执行抽卡：读取之前设定的玩家和数量，使自己抽2张卡。
function c38120068.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果对象玩家和参数，即抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因REASON_EFFECT抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
