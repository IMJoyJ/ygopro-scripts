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
-- 判定特殊召唤的来源效果是否为触发型/主动效果（EFFECT_TYPE_ACTIONS），即是否由卡的效果进行特殊召唤，从而限制只能用卡的效果特殊召唤。
function c25236056.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
