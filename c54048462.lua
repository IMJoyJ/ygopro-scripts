--魔轟神ヴァルキュルス
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：1回合1次，从手卡丢弃1只恶魔族怪兽才能发动。自己抽1张。
function c54048462.initial_effect(c)
	-- 设置同调召唤手续：以「魔轰神」怪兽为调整，调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，从手卡丢弃1只恶魔族怪兽才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54048462,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c54048462.cost)
	e1:SetTarget(c54048462.tg)
	e1:SetOperation(c54048462.op)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可丢弃的恶魔族怪兽
function c54048462.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
-- 定义效果发动的代价（Cost）处理函数
function c54048462.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己手牌中是否存在可以丢弃的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54048462.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中将1只恶魔族怪兽作为代价丢弃
	Duel.DiscardHand(tp,c54048462.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 定义效果发动的目标（Target）处理函数
function c54048462.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否可以执行抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数（抽卡数量）为1
	Duel.SetTargetParam(1)
	-- 向系统宣告此效果包含“自己抽1张卡”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理（Operation）函数
function c54048462.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前设定的效果处理对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
