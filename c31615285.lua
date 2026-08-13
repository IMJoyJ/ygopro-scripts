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
-- 过滤函数：判定卡片是否为表侧表示的植物族怪兽。
function c31615285.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 条件函数：检查场上是否存在1只除自身以外的表侧表示植物族怪兽，以决定限制特殊召唤的效果是否适用。
function c31615285.dscon(e)
	-- 检索双方怪兽区是否存在至少1张满足过滤条件（表侧植物族）且不包含效果持有者自身的卡片。
	return Duel.IsExistingMatchingCard(c31615285.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
