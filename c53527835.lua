--ダーク・シティ
-- 效果：
-- ①：「命运英雄」怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，攻击怪兽的攻击力只在伤害计算时上升1000。
function c53527835.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「命运英雄」怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，攻击怪兽的攻击力只在伤害计算时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c53527835.atkcon)
	e2:SetTarget(c53527835.atktg)
	e2:SetValue(c53527835.atkval)
	c:RegisterEffect(e2)
end
-- 定义该永续攻击力上升效果的发动条件函数，限定在伤害计算阶段且存在攻击目标时才适用。
function c53527835.atkcon(e)
	-- 判断当前是否为伤害计算阶段，并且场上存在攻击目标怪兽（若不存在则条件不成立）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 定义效果适用的怪兽筛选函数，仅将效果赋予符合条件的对象，即当前发动攻击的怪兽。
function c53527835.atktg(e,c)
	-- 筛选条件：该怪兽必须是本次战斗的攻击怪兽，并且持有「命运英雄」字段，两者同时满足才适用。
	return c==Duel.GetAttacker() and c:IsSetCard(0xc008)
end
-- 定义攻击力上升数值的计算函数，根据攻击怪兽与攻击目标的攻击力比较结果决定上升值。
function c53527835.atkval(e,c)
	-- 获取当前战斗的攻击目标怪兽，用于与攻击怪兽的攻击力进行比较。
	local d=Duel.GetAttackTarget()
	if c:GetAttack()<d:GetAttack() then
		return 1000
	else return 0 end
end
