--炎を支配する者
-- 效果：
-- 祭品召唤炎属性怪兽的场合，这只怪兽1只作为2只份的祭品使用。
function c41089128.initial_effect(c)
	-- 祭品召唤炎属性怪兽的场合，这只怪兽1只作为2只份的祭品使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c41089128.condition)
	c:RegisterEffect(e1)
end
-- 检查触发效果的怪兽是否为炎属性
function c41089128.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
