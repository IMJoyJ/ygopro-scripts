--巨人ゴーグル
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡的原本攻击力变成2100。
function c21155323.initial_effect(c)
	-- 给这张卡赋予二重怪兽属性，使其在场表侧或墓地时当作通常怪兽，并支持再度召唤的规则处理
	aux.EnableDualAttribute(c)
	-- 对应效果原文：●这张卡的原本攻击力变成2100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果只在二重怪兽处于再度召唤状态（当作效果怪兽使用）时才能适用
	e1:SetCondition(aux.IsDualState)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
end
