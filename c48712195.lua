--カードトレーダー
-- 效果：
-- 自己的准备阶段时可以让1张手卡回到卡组，从自己卡组抽1张卡。这个效果1回合只能使用1次。
function c48712195.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建诱发即时效果，用于在准备阶段发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48712195,0))  --"手牌交换"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c48712195.drcon)
	e2:SetCost(c48712195.drcost)
	e2:SetTarget(c48712195.drtg)
	e2:SetOperation(c48712195.drop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的准备阶段
function c48712195.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 设置效果的发动费用，需要支付一张手卡回到卡组
function c48712195.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可以作为费用送回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张手卡送回卡组
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 设置效果的目标，准备进行抽卡处理
function c48712195.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要进行抽卡效果处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果的处理函数，进行抽卡操作
function c48712195.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
