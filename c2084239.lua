--湿地草原
-- 效果：
-- 全部的水族·水属性·2星以下怪兽的攻击力上升1200。
function c2084239.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 全部的水族·水属性·2星以下怪兽的攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c2084239.tg)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- 作为攻击力上升效果的适用对象筛选条件，判定场上怪兽是否满足水族、水属性且等级2以下，只有满足条件的怪兽才会获得攻击力上升。注意：该函数用于e2的SetTarget，但此处的Target是永续效果的影响对象过滤器，而非发动时的取对象。
function c2084239.tg(e,c)
	return c:IsLevelBelow(2) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA)
end
