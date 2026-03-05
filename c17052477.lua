--守護神の宝札
-- 效果：
-- ①：丢弃5张手卡才能把这张卡发动。自己从卡组抽2张。
-- ②：只要这张卡在魔法与陷阱区域存在，自己抽卡阶段的通常抽卡变成2张。
function c17052477.initial_effect(c)
	-- ①：丢弃5张手卡才能把这张卡发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17052477.cost)
	e1:SetTarget(c17052477.target)
	e1:SetOperation(c17052477.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	c:RegisterEffect(e2)
end
-- 检查是否满足丢弃5张手卡的发动条件
function c17052477.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足丢弃5张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,5,e:GetHandler()) end
	-- 执行丢弃5张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,5,5,REASON_COST+REASON_DISCARD)
end
-- 检查是否可以抽2张卡
function c17052477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡效果
function c17052477.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
