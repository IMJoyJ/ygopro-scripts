--見習い魔女
-- 效果：
-- ①：场上的暗属性怪兽的攻击力上升500，光属性怪兽的攻击力下降400。
function c80741828.initial_effect(c)
	-- ①：场上的暗属性怪兽的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c80741828.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTarget(c80741828.tg2)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
-- 筛选场上的暗属性怪兽作为攻击力上升的效果适用对象
function c80741828.tg1(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 筛选场上的光属性怪兽作为攻击力下降的效果适用对象
function c80741828.tg2(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
