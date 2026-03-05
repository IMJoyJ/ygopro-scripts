--竜巻海流壁
-- 效果：
-- 场上有「海」存在的场合才能把这张卡发动。
-- ①：只要场上有「海」存在，自己受到的战斗伤害变成0。
-- ②：场上没有「海」存在的场合这张卡破坏。
function c18605135.initial_effect(c)
	-- 记录该卡与「海」相关的卡片密码，用于后续判断场地上是否存在「海」
	aux.AddCodeList(c,22702055)
	-- 场上有「海」存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c18605135.actcon)
	c:RegisterEffect(e1)
	-- 只要场上有「海」存在，自己受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c18605135.abdcon)
	c:RegisterEffect(e2)
	-- 场上没有「海」存在的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c18605135.sdcon)
	c:RegisterEffect(e3)
end
-- 检查当前场地是否存在「海」相关的场地卡
function c18605135.check()
	-- 检查当前场地是否存在「海」相关的场地卡
	return Duel.IsEnvironment(22702055)
end
-- 判断当前是否满足发动条件，即场上有「海」存在
function c18605135.actcon(e,tp,eg,ep,ev,re,r,rp)
	return c18605135.check()
end
-- 判断当前是否满足战斗伤害免除条件，即场上有「海」存在且攻击方攻击力大于防守方守备力
function c18605135.abdcon(e)
	-- 获取当前攻击目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断当前是否满足战斗伤害免除条件，即场上有「海」存在且攻击方攻击力大于防守方守备力
	return c18605135.check() and (at==nil or at:IsAttackPos() or Duel.GetAttacker():GetAttack()>at:GetDefense())
end
-- 判断当前是否满足自我破坏条件，即场地上不存在「海」相关的场地卡
function c18605135.sdcon(e)
	return not c18605135.check()
end
