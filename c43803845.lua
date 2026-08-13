--ダックドロッパー
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡不会成为效果的对象，不会被效果破坏。
-- ●只要这张卡在怪兽区域存在，对方怪兽的攻击全部变成直接攻击。
function c43803845.initial_effect(c)
	-- 为这张卡启用二重怪兽属性，使其在场上·墓地存在时当作通常怪兽使用（对应效果①）。
	aux.EnableDualAttribute(c)
	-- 不会被效果破坏（对应效果原文“●这张卡不会成为效果的对象，不会被效果破坏”中的“不会被效果破坏”）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置“不会被效果破坏”效果的条件：仅当这张卡处于再度召唤状态时才适用。
	e1:SetCondition(aux.IsDualState)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，对方怪兽的攻击全部变成直接攻击（对应效果原文“●只要这张卡在怪兽区域存在，对方怪兽的攻击全部变成直接攻击”）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置“对方怪兽攻击全部变成直接攻击”效果的条件：仅当这张卡处于再度召唤状态时才适用。
	e3:SetCondition(aux.IsDualState)
	e3:SetValue(c43803845.imval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetProperty(0)
	e4:SetValue(0)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
-- 该函数作为EFFECT_IGNORE_BATTLE_TARGET的Value值，用于判断某只怪兽是否应成为不能攻击的对象：若该怪兽不免疫作为LabelObject的e4效果，则返回true，使其不能成为攻击对象，从而实现对方怪兽只能直接攻击。
function c43803845.imval(e,c)
	return not c:IsImmuneToEffect(e:GetLabelObject())
end
