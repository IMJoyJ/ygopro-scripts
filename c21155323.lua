--巨人ゴーグル
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡的原本攻击力变成2100。
function c21155323.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡的原本攻击力变成2100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果条件为卡片处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
end
