--天岩戸
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能把灵魂怪兽以外的怪兽的效果发动。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c32181268.initial_effect(c)
	-- 为这张卡添加在召唤或反转时进入结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的值为假，使特殊召唤条件始终无法满足
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 双方不能把灵魂怪兽以外的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c32181268.aclimit)
	c:RegisterEffect(e2)
end
-- 判断发动的效果是否为非灵魂怪兽的怪兽效果
function c32181268.aclimit(e,re,tp)
	return not re:GetHandler():IsType(TYPE_SPIRIT) and re:IsActiveType(TYPE_MONSTER)
end
