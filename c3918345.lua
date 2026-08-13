--マジック・スライム
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡进行战斗所受到的对控制者的战斗伤害让对方承受。
function c3918345.initial_effect(c)
	-- 为“魔法史莱姆”添加二重怪兽属性，使其在墓地或场上表侧表示时当作通常怪兽使用，并支持再度召唤。
	aux.EnableDualAttribute(c)
	-- 这张卡变成当作效果怪兽使用并得到以下效果。●这张卡进行战斗所受到的对控制者的战斗伤害让对方承受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	-- 将战斗伤害反射效果的发动条件设为：该二重怪兽处于再度召唤状态（即当作效果怪兽使用）。
	e1:SetCondition(aux.IsDualState)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
