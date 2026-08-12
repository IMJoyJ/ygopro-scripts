--M・HERO ヴェイパー
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。这张卡不会被魔法·陷阱·效果怪兽的效果破坏。
function c10920352.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过假面变化方式召唤。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被魔法·陷阱·效果怪兽的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
