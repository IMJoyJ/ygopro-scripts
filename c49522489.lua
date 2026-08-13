--悪魔ガエル
-- 效果：
-- 这张卡的攻击力上升自己墓地存在的「恶魂邪苦止」的数量×300的数值。
function c49522489.initial_effect(c)
	-- 这张卡的攻击力上升自己墓地存在的「恶魂邪苦止」的数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c49522489.val)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升数值的计算函数：统计自己墓地中存在的「恶魂邪苦止」数量并乘以300作为攻击力提升值。
function c49522489.val(e,c)
	-- 统计自己墓地中卡号为10456559（恶魂邪苦止）的卡的数量，并乘以300作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,10456559)*300
end
