--ヘルカイザー・ドラゴン
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
function c95888876.initial_effect(c)
	-- 为卡片注册二重怪兽的通用属性与规则
	aux.EnableDualAttribute(c)
	-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	-- 设置效果的启用条件为该怪兽处于再度召唤状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	c:RegisterEffect(e1)
end
