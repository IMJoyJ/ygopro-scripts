--ヴァリュアブル・アーマー
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡可以向对方场上的全部怪兽各作1次攻击。
function c95166228.initial_effect(c)
	-- 为卡片添加二重怪兽属性，使其在墓地或场上表侧表示时当作通常怪兽，并可进行再度召唤
	aux.EnableDualAttribute(c)
	-- ●这张卡可以向对方场上的全部怪兽各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	-- 设置效果生效条件为该怪兽处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
