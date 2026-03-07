--サボウ・クローザー
-- 效果：
-- 这张卡不能特殊召唤。只要这张卡以外的植物族怪兽在场上表侧表示存在，双方不能把怪兽特殊召唤。
function c31615285.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 只要这张卡以外的植物族怪兽在场上表侧表示存在，双方不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c31615285.dscon)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在满足条件的植物族怪兽（表侧表示）
function c31615285.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 条件函数，判断是否满足特殊召唤限制条件（场上存在其他植物族表侧表示怪兽）
function c31615285.dscon(e)
	-- 检索满足条件的卡片组，检查场上是否存在至少1张满足filter条件的怪兽
	return Duel.IsExistingMatchingCard(c31615285.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
