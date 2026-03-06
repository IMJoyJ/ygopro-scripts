--魔轟神獣コカトル
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以从手卡丢弃1只名字带有「魔轰神」的怪兽，从自己卡组抽1张卡。
function c26704411.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以从手卡丢弃1只名字带有「魔轰神」的怪兽，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26704411,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否为战斗破坏对方怪兽送去墓地的情况
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(c26704411.cost)
	e1:SetTarget(c26704411.tg)
	e1:SetOperation(c26704411.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中名字带有「魔轰神」的怪兽
function c26704411.costfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时的费用处理，丢弃1只名字带有「魔轰神」的怪兽
function c26704411.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26704411.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1只名字带有「魔轰神」的怪兽的操作
	Duel.DiscardHand(tp,c26704411.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 设置效果的发动目标，确定抽卡数量
function c26704411.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时执行的操作，使玩家抽1张卡
function c26704411.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
