--カイザー・シーホース
-- 效果：
-- ①：光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c17444133.initial_effect(c)
	-- ①：光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c17444133.condition)
	c:RegisterEffect(e1)
end
-- 双祭品条件：用于光属性怪兽的上级召唤
function c17444133.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_LIGHT) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
