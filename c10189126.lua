--仮面魔道士
-- 效果：
-- 这张卡造成对方玩家基本分伤害的时候，自己抽1张卡。
function c10189126.initial_effect(c)
	-- 创建一个诱发必发效果，当这张卡造成对方玩家基本分伤害时触发，效果描述为抽卡，类别为抽卡，以玩家为对象，触发条件是造成战斗伤害时，且受伤方不是自己；目标是自己抽1张卡，操作为执行抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10189126,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c10189126.condition)
	e1:SetTarget(c10189126.target)
	e1:SetOperation(c10189126.operation)
	c:RegisterEffect(e1)
end
-- 定义条件检查函数，确保效果只在玩家受到对方造成的战斗伤害时触发
function c10189126.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 定义目标选择函数，设定效果的目标玩家和参数，并设置操作信息
function c10189126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为发动此效果的玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1，表示抽1张卡
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息，表明这是一个抽卡效果，预计处理数量为1，由自己从牌组抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数，用于执行实际的抽卡操作
function c10189126.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数，即抽卡的玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，使目标玩家以效果原因抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
