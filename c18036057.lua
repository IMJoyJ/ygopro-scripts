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
-- 效果发动的条件：造成战斗伤害的玩家不是自己
function c18036057.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置效果的对象玩家和参数，准备执行抽卡效果
function c18036057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设置为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡效果，目标玩家为tp，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作，从卡组抽取指定数量的卡
function c18036057.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡，原因来自效果
	Duel.Draw(p,d,REASON_EFFECT)
end
