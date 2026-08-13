--古代の機械騎士
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c39303359.initial_effect(c)
	-- 为这张卡添加二重怪兽属性，使其可作为二重怪兽处理。
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
-- 判断对方发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），若是则被此效果禁止。
function c39303359.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 发动条件：这张卡处于再度召唤状态，并且这张卡就是当前进行攻击的怪兽。
function c39303359.actcon(e)
	-- 该效果仅当这张卡处于再度召唤状态且为攻击怪兽时才生效。
	return aux.IsDualState(e) and Duel.GetAttacker()==e:GetHandler()
end
