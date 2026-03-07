--威光魔人
-- 效果：
-- 这张卡不能特殊召唤。只要这张卡在场上表侧表示存在，双方不能把效果怪兽的效果发动。
function c33746252.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，双方不能把效果怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(c33746252.aclimit)
	c:RegisterEffect(e2)
end
-- 判断效果是否作用于怪兽类型，用于限制怪兽效果的发动。
function c33746252.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
