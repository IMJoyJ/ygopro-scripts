--天岩戸
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能把灵魂怪兽以外的怪兽的效果发动。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c32181268.initial_effect(c)
	-- 为这张卡登记灵魂怪兽的返回手卡效果：在召唤成功或反转的回合结束阶段，这张卡回到持有者手卡（对应②效果）。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为恒为false，使这张卡永远无法满足特殊召唤条件，从而禁止特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，双方不能把灵魂怪兽以外的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c32181268.aclimit)
	c:RegisterEffect(e2)
end
-- 作为EFFECT_CANNOT_ACTIVATE的值判定函数：当被发动的效果是怪兽效果，且该效果所属的怪兽不是灵魂怪兽时，返回true以禁止发动；否则返回false。
function c32181268.aclimit(e,re,tp)
	return not re:GetHandler():IsType(TYPE_SPIRIT) and re:IsActiveType(TYPE_MONSTER)
end
