--デュアル・ランサー
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c26254876.initial_effect(c)
	-- 为二重枪兵添加二重怪兽属性，使其在墓地或场上表侧表示时当作通常怪兽使用，并支持再度召唤。
	aux.EnableDualAttribute(c)
	-- ●这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	-- 设置贯穿伤害效果仅在二重怪兽处于再度召唤状态时适用，即变成效果怪兽后才能发动贯穿伤害。
	e1:SetCondition(aux.IsDualState)
	c:RegisterEffect(e1)
end
