--サイバー・ウロボロス
-- 效果：
-- 这张卡从游戏中除外时，可以把手卡1张卡送去墓地，从卡组抽1张卡。
function c30042158.initial_effect(c)
	-- 效果原文内容：这张卡从游戏中除外时，可以把手卡1张卡送去墓地，从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30042158,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCost(c30042158.cost)
	e1:SetTarget(c30042158.target)
	e1:SetOperation(c30042158.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足费用条件并执行费用丢弃手卡1张到墓地的操作
function c30042158.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在至少1张可以作为费用送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡1张满足条件的卡到墓地的操作
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 检查玩家是否可以抽卡并设置抽卡目标
function c30042158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁效果的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果的处理函数，从卡组抽1张卡
function c30042158.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行从卡组抽1张卡的效果
	Duel.Draw(p,d,REASON_EFFECT)
end
