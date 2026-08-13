--ガイアフレーム
-- 效果：
-- 地属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
function c53461122.initial_effect(c)
	-- 地属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c53461122.condition)
	c:RegisterEffect(e1)
end
-- 定义该效果的条件判定函数：检查作为祭品的怪兽是否满足地属性且为通常怪兽，满足时该怪兽可作为2只祭品使用。
function c53461122.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_NORMAL)
end
