--死のメッセージ「E」
-- 效果：
-- 这张卡不用「通灵盘」的效果不能在场上出现。
function c31893528.initial_effect(c)
	-- 对应效果原文：“这张卡不用「通灵盘」的效果不能在场上出现。”——通过EFFECT_CANNOT_SSET实现“不能在场上出现”中的不能将这张卡覆盖到魔法与陷阱区域。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡不用「通灵盘」的效果不能在场上出现。”——通过EFFECT_SPSUMMON_COST与spcost限定此卡只能以「通灵盘」的效果（暗黑圣域的特殊召唤方式）特殊召唤，否则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetCost(c31893528.spcost)
	c:RegisterEffect(e2)
end
-- 规则层面：spcost作为特殊召唤代价条件的判定函数，检查本次特殊召唤的sumtype是否等于SUMMON_TYPE_SPECIAL加上SUMMON_VALUE_DARK_SANCTUARY（即暗黑圣域的特殊召唤方式），只有来自「通灵盘」效果（经由暗黑圣域）的特殊召唤才满足条件，从而限制此卡不能通过其他方式在场上出现。
function c31893528.spcost(e,c,tp,sumtype)
	return sumtype==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_DARK_SANCTUARY
end
