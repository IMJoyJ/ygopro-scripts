--ハーピィ・レディ1
-- 效果：
-- 这张卡的卡名当作「鹰身女郎」使用。只要这张卡在场上存在，场上的风属性怪兽攻击力上升300。
function c91932350.initial_effect(c)
	-- 只要这张卡在场上存在，场上的风属性怪兽攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果的影响对象为风属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(300)
	c:RegisterEffect(e1)
end
