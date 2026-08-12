--紫炎の霞城
-- 效果：
-- 名字带有「六武众」的怪兽被攻击时，攻击怪兽的攻击力下降500。
function c11102908.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
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
-- 效果适用的条件：在伤害计算阶段且攻击对象是六武众怪兽时生效
function c11102908.atkcon(e)
	-- 获取当前正在被攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 判断当前阶段是否为伤害计算阶段且攻击目标存在且为六武众怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and d and d:IsSetCard(0x103d)
end
-- 效果适用的目标：攻击怪兽
function c11102908.atktg(e,c)
	-- 目标为当前攻击怪兽
	return c==Duel.GetAttacker()
end
