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
-- 设置目标为满足等级2以下、水属性、水族种族的怪兽
function c2084239.tg(e,c)
	return c:IsLevelBelow(2) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA)
end
