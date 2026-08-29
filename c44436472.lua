--ダブルコストン
-- 效果：
-- ①：暗属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c44436472.initial_effect(c)
	-- ①：暗属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c44436472.condition)
	c:RegisterEffect(e1)
end
-- 判定作为解放的怪兽是否为暗属性，若是则这张卡可作为2只数量解放。
function c44436472.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_DARK) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
