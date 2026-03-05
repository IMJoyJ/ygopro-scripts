--暴風小僧
-- 效果：
-- 祭品召唤风属性怪兽的场合，这只怪兽1只作为2只份的祭品使用。
function c15090429.initial_effect(c)
	-- 祭品召唤风属性怪兽的场合，这只怪兽1只作为2只份的祭品使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c15090429.condition)
	c:RegisterEffect(e1)
end
-- 当卡片效果适用时，检查该怪兽是否为风属性
function c15090429.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
