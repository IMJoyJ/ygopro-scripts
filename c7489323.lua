--ミリス・レディエント
-- 效果：
-- 只要这张卡在场上表侧表示存在，全部地属性的怪兽攻击力上升500。风属性的怪兽攻击力下降400。
function c7489323.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，全部地属性的怪兽攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c7489323.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTarget(c7489323.tg2)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
-- 过滤出地属性怪兽作为效果影响对象
function c7489323.tg1(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 过滤出风属性怪兽作为效果影响对象
function c7489323.tg2(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
