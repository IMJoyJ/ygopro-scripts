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
-- 作为EFFECT_DOUBLE_TRIBUTE的判定条件：当此卡被用于祭品召唤风属性怪兽时返回true，即此卡可作为2只祭品。
function c15090429.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_WIND) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
