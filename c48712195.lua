--カードトレーダー
-- 效果：
-- 自己的准备阶段时可以让1张手卡回到卡组，从自己卡组抽1张卡。这个效果1回合只能使用1次。
function c48712195.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时可以让1张手卡回到卡组，从自己卡组抽1张卡。这个效果1回合只能使用1次。
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
-- 该函数为效果的发动条件，用于判定当前回合玩家是否为效果控制者，即是否是“自己的准备阶段”。
function c48712195.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于效果发动者tp，确保效果只在自己回合的准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 该函数为效果的发动代价，要求从手牌选1张卡返回卡组并洗牌，对应“让1张手卡回到卡组”这一代价。
function c48712195.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk=0）确认己方手牌中是否存在可以作为代价返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让玩家选择要返回卡组的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让己方tp从手牌中选择1张可以作为代价返回卡组的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌送去其持有者的卡组并洗牌，作为发动效果的代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 该函数为效果发动时的目标设定，确认玩家可以抽卡，并设定抽卡玩家和抽卡数量供处理阶段使用。
function c48712195.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段（chk=0）确认己方tp能够抽1张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为tp，即抽卡玩家为效果发动者自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，即抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记本次效果的操作信息为抽卡效果，预计让玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 该函数为效果处理时的实际动作，从连锁信息中取出抽卡玩家和数量并执行抽卡，对应“从自己卡组抽1张卡”。
function c48712195.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前设定的对象玩家p和对象参数d，分别表示抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡，完成抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
