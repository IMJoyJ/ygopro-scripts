--リトル・キメラ
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上的炎属性怪兽的攻击力上升500，水属性怪兽的攻击力下降400。
function c68658728.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，场上的炎属性怪兽的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c68658728.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTarget(c68658728.tg2)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
-- 过滤出场上的炎属性怪兽作为攻击力上升的效果对象
function c68658728.tg1(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 过滤出场上的水属性怪兽作为攻击力下降的效果对象
function c68658728.tg2(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
