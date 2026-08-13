--死のメッセージ「H」
-- 效果：
-- 这张卡不用「通灵盘」的效果不能在场上出现。
function c30170981.initial_effect(c)
	-- 对应效果原文『这张卡不用「通灵盘」的效果不能在场上出现。』：设置不能覆盖到魔法与陷阱区域的永续效果，使这张卡不能通过覆盖方式出现在场上。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)
	-- 对应效果原文『这张卡不用「通灵盘」的效果不能在场上出现。』：设置特殊召唤代价效果，限定只有特殊召唤类型满足SUMMON_TYPE_SPECIAL+SUMMON_VALUE_DARK_SANCTUARY时才允许特殊召唤，从而限制出场方式。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetCost(c30170981.spcost)
	c:RegisterEffect(e2)
end
-- 特殊召唤代价判定函数：检查本次特殊召唤的sumtype是否等于SUMMON_TYPE_SPECIAL与SUMMON_VALUE_DARK_SANCTUARY的组合值（即由暗黑圣域进行的特殊召唤），是则允许，否则禁止该特殊召唤。
function c30170981.spcost(e,c,tp,sumtype)
	return sumtype==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_DARK_SANCTUARY
end
