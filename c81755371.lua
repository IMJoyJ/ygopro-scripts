--ダークフレーム
-- 效果：
-- 暗属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
function c81755371.initial_effect(c)
	-- 暗属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c81755371.condition)
	c:RegisterEffect(e1)
end
-- 判断进行祭品召唤的怪兽是否为暗属性的通常怪兽
function c81755371.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_NORMAL)
end
