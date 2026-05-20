--虚無の統括者
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能把怪兽特殊召唤。
function c72634965.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终为假，从而使该卡不能被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
end
