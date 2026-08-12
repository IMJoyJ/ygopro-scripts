--第二の棺
-- 效果：
-- 这张卡只能通过「第一之棺」的效果上场。
function c4081094.initial_effect(c)
	-- 这张卡只能通过「第一之棺」的效果上场。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)
	-- 这张卡只能通过「第一之棺」的效果上场。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e2)
end
