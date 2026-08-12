--死のメッセージ「T」
-- 效果：
-- 这张卡不用「通灵盘」的效果不能在场上出现。
function c94772232.initial_effect(c)
	-- 这张卡不用「通灵盘」的效果不能在场上出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)
	-- 这张卡不用「通灵盘」的效果不能在场上出现。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetCost(c94772232.spcost)
	c:RegisterEffect(e2)
end
-- 限制特殊召唤的条件，仅允许通过「暗黑圣域」的效果（在规则上视作「通灵盘」的效果）进行特殊召唤
function c94772232.spcost(e,c,tp,sumtype)
	return sumtype==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_DARK_SANCTUARY
end
