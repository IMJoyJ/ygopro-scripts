--サイレント・マジシャン LV8
-- 效果：
-- 这张卡不能通常召唤，用「沉默魔术师 LV4」的效果才能特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不受对方的魔法卡的效果影响。
function c72443568.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「沉默魔术师 LV4」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不可特殊召唤，使其只能通过特定的卡片效果来特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在怪兽区域存在，不受对方的魔法卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c72443568.efilter)
	c:RegisterEffect(e2)
end
c72443568.lvup={73665146}
c72443568.lvdn={73665146}
-- 免疫效果的筛选函数，判定效果是否为对方玩家的魔法卡效果
function c72443568.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
