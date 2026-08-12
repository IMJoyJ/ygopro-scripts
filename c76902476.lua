--幻獣機タートレーサー
-- 效果：
-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，只要这张卡在场上表侧表示存在，1回合1次，自己场上的「幻兽机衍生物」不会被战斗破坏。
function c76902476.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c76902476.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果生效条件为自己场上存在衍生物。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 此外，只要这张卡在场上表侧表示存在，1回合1次，自己场上的「幻兽机衍生物」不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c76902476.indtg)
	e4:SetCountLimit(1)
	e4:SetValue(c76902476.valcon)
	c:RegisterEffect(e4)
end
-- 等级上升数值的计算函数，返回自己场上「幻兽机衍生物」的等级合计值。
function c76902476.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有卡名为「幻兽机衍生物」的怪兽，并计算它们的等级合计值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 目标过滤函数，使效果仅适用于卡名为「幻兽机衍生物」的怪兽。
function c76902476.indtg(e,c)
	return c:IsCode(31533705)
end
-- 保护类型判定函数，设定仅在因战斗破坏时适用该抗性。
function c76902476.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
