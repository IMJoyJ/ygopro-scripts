--インヴェルズの歩哨
-- 效果：
-- 只要这张卡在场上表侧攻击表示存在，场上表侧表示存在的5星以上的特殊召唤的怪兽不能把效果发动。
function c99214782.initial_effect(c)
	-- 只要这张卡在场上表侧攻击表示存在，场上表侧表示存在的5星以上的特殊召唤的怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c99214782.condition)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c99214782.target)
	c:RegisterEffect(e1)
end
-- 该效果的条件判断：当这张卡自身处于表侧攻击表示时，效果才适用。
function c99214782.condition(e)
	return e:GetHandler():IsAttackPos()
end
-- 该效果的目标筛选：只有等级为5星以上且通过特殊召唤方式出场的怪兽，才会被禁止发动效果。
function c99214782.target(e,c)
	return c:IsLevelAbove(5) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
