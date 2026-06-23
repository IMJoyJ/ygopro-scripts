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
-- 检索满足条件的卡片组，即自己墓地存在的「恶魂邪苦止」的数量
function c49522489.val(e,c)
	-- 将检索到的卡片数量乘以300作为攻击力的增加量
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,10456559)*300
end
