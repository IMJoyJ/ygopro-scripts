--摩天楼 －スカイスクレイパー－
-- 效果：
-- ①：「元素英雄」怪兽的攻击力只在向持有比自身的攻击力高的攻击力的怪兽攻击的伤害计算时上升1000。
function c63035430.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：「元素英雄」怪兽的攻击力只在向持有比自身的攻击力高的攻击力的怪兽攻击的伤害计算时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c63035430.atkcon)
	e2:SetTarget(c63035430.atktg)
	e2:SetValue(c63035430.atkval)
	c:RegisterEffect(e2)
end
-- 设置效果的生效条件判定函数，仅在伤害计算时且存在攻击对象时生效
function c63035430.atkcon(e)
	-- 返回当前阶段是否为伤害计算时，且当前存在被攻击的怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 设置效果的影响对象判定函数，用于筛选符合条件的「元素英雄」怪兽
function c63035430.atktg(e,c)
	-- 判定该怪兽是否为当前的攻击怪兽，且属于「元素英雄」系列
	return c==Duel.GetAttacker() and c:IsSetCard(0x3008)
end
-- 计算并返回攻击力上升的数值，若自身攻击力低于攻击对象则上升1000
function c63035430.atkval(e,c)
	-- 获取当前战斗中被攻击的怪兽（攻击目标）
	local d=Duel.GetAttackTarget()
	if c:GetAttack()<d:GetAttack() then
		return 1000
	else return 0 end
end
