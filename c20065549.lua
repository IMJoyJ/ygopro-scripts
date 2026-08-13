--絶対魔法禁止区域
-- 效果：
-- 场上所有表侧表示的效果怪兽以外的怪兽不受魔法效果的影响。
function c20065549.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上所有表侧表示的效果怪兽以外的怪兽不受魔法效果的影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c20065549.etarget)
	e2:SetValue(c20065549.efilter)
	c:RegisterEffect(e2)
end
-- 匹配场上非效果怪兽作为不受魔法效果影响的适用对象。
function c20065549.etarget(e,c)
	return not c:IsType(TYPE_EFFECT)
end
-- 判断效果来源是否为魔法效果（仅当来源是魔法卡时给予免疫）。
function c20065549.efilter(e,re)
	return re:IsActiveType(TYPE_SPELL)
end
