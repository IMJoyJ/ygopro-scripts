--スター・ボーイ
-- 效果：
-- 只要这张卡在场上表侧表示存在，全部水属性的怪兽攻击力上升500。炎属性的怪兽攻击力下降400。
function c8201910.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，全部水属性的怪兽攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c8201910.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTarget(c8201910.tg2)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
-- 筛选场上的水属性怪兽作为攻击力上升的影响对象
function c8201910.tg1(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选场上的炎属性怪兽作为攻击力下降的影响对象
function c8201910.tg2(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
