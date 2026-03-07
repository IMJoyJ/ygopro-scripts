--マジック・スライム
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡进行战斗所受到的对控制者的战斗伤害让对方承受。
function c3918345.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡进行战斗所受到的对控制者的战斗伤害让对方承受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	-- 设置效果的发动条件为卡片处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
