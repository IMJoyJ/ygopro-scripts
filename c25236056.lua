--レアメタル・ドラゴン
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
function c25236056.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c25236056.splimit)
	c:RegisterEffect(e1)
end
-- 效果满足条件时才能特殊召唤
function c25236056.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
