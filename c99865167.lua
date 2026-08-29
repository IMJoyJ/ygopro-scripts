--ウィンドフレーム
-- 效果：
-- 风属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
function c99865167.initial_effect(c)
	-- 风属性的通常怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c99865167.condition)
	c:RegisterEffect(e1)
end
-- 判定可作为2只祭品的条件：满足风属性且为通常怪兽的怪兽才能使用此效果。
function c99865167.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_NORMAL) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
