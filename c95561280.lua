--猛毒の風
-- 效果：
-- 只要这张卡在场上存在，双方不能把风属性怪兽特殊召唤。此外，场上表侧表示存在的全部风属性怪兽的攻击力下降500。
function c95561280.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的全部风属性怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c95561280.tg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，双方不能把风属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c95561280.tg)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为风属性
function c95561280.tg(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
