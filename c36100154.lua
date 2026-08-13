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
-- 伤害计算阶段且存在攻击对象、攻击怪兽的控制者为这张卡持有者时，满足此永续效果的发动条件。
function c36100154.atkcon(e)
	-- 判定当前阶段为伤害计算时（PHASE_DAMAGE_CAL）且存在攻击对象（Duel.GetAttackTarget()），以确保处于战斗伤害计算中。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
		-- 判定攻击怪兽（Duel.GetAttacker()）的控制者即为本卡的效果持有者（e:GetHandlerPlayer()），即只有己方怪兽攻击时才适用。
		and Duel.GetAttacker():IsControler(e:GetHandlerPlayer())
end
-- 设置攻击力上升效果的适用对象：必须是当前攻击怪兽，且该怪兽卡名带有「亚马逊」字段（0x4）。
function c36100154.atktg(e,c)
	-- 确认目标卡正是攻击怪兽，并且其具有「亚马逊」字段（0x4），满足这两个条件才可接受攻击力上升。
	return c==Duel.GetAttacker() and c:IsSetCard(0x4)
end
-- 计算攻击力上升数值：当攻击怪兽当前攻击力低于攻击对象的攻击力时，上升1000；否则上升0（实际无提升）。
function c36100154.atkval(e,c)
	-- 获取当前攻击对象（被攻击的怪兽）作为攻击力比较的基准。
	local d=Duel.GetAttackTarget()
	if c:GetAttack()<d:GetAttack() then
		return 1000
	else return 0 end
end
