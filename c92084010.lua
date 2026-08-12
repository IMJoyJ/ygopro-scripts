--ヒゲアンコウ
-- 效果：
-- 作为水属性怪兽祭品召唤的场合，这只怪兽1只可以作为2只份的祭品使用。
function c92084010.initial_effect(c)
	-- 作为水属性怪兽祭品召唤的场合，这只怪兽1只可以作为2只份的祭品使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c92084010.condition)
	c:RegisterEffect(e1)
end
-- 判断进行祭品召唤的怪兽是否为水属性
function c92084010.condition(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
