--重装武者－ベン・ケイ
-- 效果：
-- 每次的战斗阶段中，这张卡在通常攻击之上追加、这张卡装备的装备卡数量的攻击次数。
function c84430950.initial_effect(c)
	-- 每次的战斗阶段中，这张卡在通常攻击之上追加、这张卡装备的装备卡数量的攻击次数。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(c84430950.val)
	c:RegisterEffect(e1)
end
-- 获取自身装备的装备卡数量，作为追加攻击的次数
function c84430950.val(e,c)
	return c:GetEquipCount()
end
