--アマゾネスの闘志
-- 效果：
-- 名字带有「亚马逊」的怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，只在伤害计算时攻击怪兽的攻击力上升1000。
function c36100154.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名字带有「亚马逊」的怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，只在伤害计算时攻击怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c36100154.atkcon)
	e2:SetTarget(c36100154.atktg)
	e2:SetValue(c36100154.atkval)
	c:RegisterEffect(e2)
end
-- 伤害计算时触发条件检查
function c36100154.atkcon(e)
	-- 当前阶段为伤害计算阶段
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
		-- 攻击怪兽为我方控制的怪兽
		and Duel.GetAttacker():IsControler(e:GetHandlerPlayer())
end
-- 效果适用目标检查
function c36100154.atktg(e,c)
	-- 目标怪兽为当前攻击怪兽且为亚马逊族
	return c==Duel.GetAttacker() and c:IsSetCard(0x4)
end
-- 攻击力变更值计算
function c36100154.atkval(e,c)
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if c:GetAttack()<d:GetAttack() then
		return 1000
	else return 0 end
end
