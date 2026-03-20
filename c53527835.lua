--ダーク・シティ
-- 效果：
-- ①：「命运英雄」怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，攻击怪兽的攻击力只在伤害计算时上升1000。
function c53527835.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：「命运英雄」怪兽向持有比那个攻击力高的攻击力的怪兽攻击的场合，攻击怪兽的攻击力只在伤害计算时上升1000。
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
-- 规则层面作用：判断是否处于伤害计算阶段且存在攻击对象
function c53527835.atkcon(e)
	-- 规则层面作用：当前阶段为伤害计算阶段且存在攻击目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 规则层面作用：筛选攻击怪兽并确认其为「命运英雄」卡组
function c53527835.atktg(e,c)
	-- 规则层面作用：目标怪兽等于当前攻击怪兽且为「命运英雄」卡组
	return c==Duel.GetAttacker() and c:IsSetCard(0xc008)
end
-- 规则层面作用：根据攻击力比较决定是否增加1000攻击力
function c53527835.atkval(e,c)
	-- 规则层面作用：获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if c:GetAttack()<d:GetAttack() then
		return 1000
	else return 0 end
end
