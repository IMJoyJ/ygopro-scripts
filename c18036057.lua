--天空騎士パーシアス
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡给与对方战斗伤害的场合发动。自己从卡组抽1张。
function c18036057.initial_effect(c)
	-- ②：这张卡给与对方战斗伤害的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18036057,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c18036057.condition)
	e1:SetTarget(c18036057.target)
	e1:SetOperation(c18036057.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 判断受到战斗伤害的玩家是否为这张卡的控制者的对手（ep不等于tp），即满足“给与对方战斗伤害”的发动条件。
function c18036057.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时进行合法性检查并设定抽卡相关参数：将目标玩家设为自己、抽卡数量设为1，同时登记抽卡效果的操作信息。
function c18036057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设定为这张卡的控制者（自己），即抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果对象参数设定为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记本次连锁将执行的操作为抽卡效果：目标玩家为tp，预计抽卡数量为1，不指定具体卡组中的卡片对象。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时，从连锁信息中取出之前设定的目标玩家和抽卡数量，并执行对应次数的抽卡。
function c18036057.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取记录的目标玩家（抽卡者）和参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
