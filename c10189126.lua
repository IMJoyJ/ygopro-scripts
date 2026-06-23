--仮面魔道士
-- 效果：
-- 这张卡造成对方玩家基本分伤害的时候，自己抽1张卡。
function c10189126.initial_effect(c)
	-- 这张卡造成对方玩家基本分伤害的时候，自己抽1张卡。
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
-- 触发条件：造成对方战斗伤害时
function c10189126.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动准备：设置抽卡的目标玩家和参数，并设置抽卡的操作信息
function c10189126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：获取目标玩家与抽卡数量，执行抽卡
function c10189126.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家以及要抽卡的数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
