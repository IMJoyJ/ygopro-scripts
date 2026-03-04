--紫炎の霞城
-- 效果：
-- 名字带有「六武众」的怪兽被攻击时，攻击怪兽的攻击力下降500。
function c11102908.initial_effect(c)
	-- 名字带有「六武众」的怪兽被攻击时，攻击怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名字带有「六武众」的怪兽被攻击时，攻击怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c11102908.atkcon)
	e2:SetTarget(c11102908.atktg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
end
-- 判断是否处于伤害计算阶段且攻击对象存在且为六武众卡组怪兽
function c11102908.atkcon(e)
	-- 获取当前攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 判断是否处于伤害计算阶段且攻击目标存在且为六武众卡组怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and d and d:IsSetCard(0x103d)
end
-- 判断当前被攻击的怪兽是否为攻击怪兽
function c11102908.atktg(e,c)
	-- 返回当前攻击怪兽
	return c==Duel.GetAttacker()
end
