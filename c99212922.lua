--白竜の忍者
-- 效果：
-- 这张卡特殊召唤的场合，用名字带有「忍法」的卡的效果才能特殊召唤。只要这张卡在场上表侧表示存在，自己场上的魔法·陷阱卡不会被卡的效果破坏。
function c99212922.initial_effect(c)
	-- 这张卡特殊召唤的场合，用名字带有「忍法」的卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c99212922.splimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，自己场上的魔法·陷阱卡不会被卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c99212922.indes)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：仅当将这张卡特殊召唤的效果的来源卡满足「忍法」字段时，才允许特殊召唤。
function c99212922.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x61)
end
-- 效果耐性对象判定：仅当被破坏保护的卡是魔法·陷阱卡时，才赋予其不会被效果破坏的耐性。
function c99212922.indes(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
