--スーパースター
-- 效果：
-- ①：场上的光属性怪兽的攻击力上升500，暗属性怪兽的攻击力下降400。
function c67629977.initial_effect(c)
	-- ①：场上的光属性怪兽的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(c67629977.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTarget(c67629977.tg2)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
-- 过滤出场上的光属性怪兽作为攻击力上升效果的影响对象
function c67629977.tg1(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤出场上的暗属性怪兽作为攻击力下降效果的影响对象
function c67629977.tg2(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
