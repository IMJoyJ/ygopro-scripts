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
-- 检查触发上级召唤的怪兽是否为暗属性
function c44436472.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
