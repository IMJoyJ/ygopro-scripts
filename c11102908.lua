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
-- 效果发动条件判断：当前阶段为伤害计算时，且被攻击的怪兽为名字带有「六武众」的怪兽时，该效果才适用。
function c11102908.atkcon(e)
	-- 获取当前战斗阶段被攻击的怪兽对象。
	local d=Duel.GetAttackTarget()
	-- 判断当前是否为伤害计算阶段、存在被攻击对象且该对象属于「六武众」字段，三者同时满足时条件成立。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and d and d:IsSetCard(0x103d)
end
-- 指定受到攻击力下降效果影响的怪兽对象。
function c11102908.atktg(e,c)
	-- 确定只有当前发动攻击的怪兽才会被选中作为攻击力下降的对象。
	return c==Duel.GetAttacker()
end
