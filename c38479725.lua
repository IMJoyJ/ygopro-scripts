--トロイホース
-- 效果：
-- 作为地属性怪兽祭品召唤的场合，这只怪兽1只可以作为2只份的祭品使用。
function c38479725.initial_effect(c)
	-- 作为地属性怪兽祭品召唤的场合，这只怪兽1只可以作为2只份的祭品使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c38479725.condition)
	c:RegisterEffect(e1)
end
-- 双祭品效果适用条件：地属性怪兽上级召唤且自身表侧表示或同控制者
function c38479725.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_EARTH) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
