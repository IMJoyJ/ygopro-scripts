--古代の機械騎士
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c39303359.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c39303359.aclimit)
	e1:SetCondition(c39303359.actcon)
	c:RegisterEffect(e1)
end
-- 限制发动的魔法·陷阱卡类型为魔法·陷阱卡
function c39303359.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为再度召唤状态且当前攻击的卡为该卡
function c39303359.actcon(e)
	-- 判断是否为再度召唤状态且当前攻击的卡为该卡
	return aux.IsDualState(e) and Duel.GetAttacker()==e:GetHandler()
end
