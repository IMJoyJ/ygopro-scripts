--ドリル・シンクロン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的战士族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，这张卡的①的效果适用给与对方战斗伤害时才能发动。自己从卡组抽1张。
function c56286179.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的战士族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c56286179.ptg)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡的①的效果适用给与对方战斗伤害时才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56286179,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c56286179.drcon)
	e2:SetTarget(c56286179.drtg)
	e2:SetOperation(c56286179.drop)
	c:RegisterEffect(e2)
end
-- 过滤受贯穿效果影响的怪兽，限定为我方的战士族怪兽
function c56286179.ptg(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 判断发动条件：对方受到战斗伤害，且该伤害是由我方战士族怪兽攻击守备表示怪兽时产生的（即①的效果适用）
function c56286179.drcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsDefensePos() and a:IsControler(tp) and a:IsRace(RACE_WARRIOR)
end
-- 抽卡效果的发动准备，检查是否能抽卡并设置效果目标与操作信息
function c56286179.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动性检测时，检查当前玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前玩家设为效果处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 将抽卡数量1设为效果处理的目标参数
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行，获取目标玩家和抽卡数量并执行抽卡
function c56286179.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
