--竜巻海流壁
-- 效果：
-- 场上有「海」存在的场合才能把这张卡发动。
-- ①：只要场上有「海」存在，自己受到的战斗伤害变成0。
-- ②：场上没有「海」存在的场合这张卡破坏。
function c18605135.initial_effect(c)
	-- 将卡号22702055（「海」）登记为这张卡效果文本中记载的卡名，用于配合效果中的『海』判定。
	aux.AddCodeList(c,22702055)
	-- 场上有「海」存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c18605135.actcon)
	c:RegisterEffect(e1)
	-- ①：只要场上有「海」存在，自己受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c18605135.abdcon)
	c:RegisterEffect(e2)
	-- ②：场上没有「海」存在的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c18605135.sdcon)
	c:RegisterEffect(e3)
end
-- 此函数用于检查当前场上是否存在「海」（卡号22702055），供各效果的发动/适用条件使用。
function c18605135.check()
	-- 调用Duel.IsEnvironment判断当前场上是否存在「海」（22702055），返回布尔值。
	return Duel.IsEnvironment(22702055)
end
-- e1的发动条件：若场上存在「海」，则允许发动这张卡（对应『场上有「海」存在的场合才能把这张卡发动』）。
function c18605135.actcon(e,tp,eg,ep,ev,re,r,rp)
	return c18605135.check()
end
-- e2的适用条件：场上存在「海」且本次攻击属于会造成战斗伤害的情形（直接攻击、攻击表示被攻击或攻击力超过守备力），此时自己受到的战斗伤害变成0。
function c18605135.abdcon(e)
	-- 获取此次战斗被攻击的怪兽；直接攻击时为nil，用于判断是否会有战斗伤害。
	local at=Duel.GetAttackTarget()
	-- 返回是否为『场上存在「海」且会造成战斗伤害』：直接攻击或攻击目标为攻击表示或攻击力高于目标守备力。
	return c18605135.check() and (at==nil or at:IsAttackPos() or Duel.GetAttacker():GetAttack()>at:GetDefense())
end
-- e3的自我破坏条件：场上没有「海」存在时，这张卡被破坏（对应效果②）。
function c18605135.sdcon(e)
	return not c18605135.check()
end
