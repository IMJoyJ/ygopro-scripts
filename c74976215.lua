--クロスソード・ハンター
-- 效果：
-- 自己场上有这张卡以外的昆虫族怪兽存在的场合，自己场上存在的昆虫族怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c74976215.initial_effect(c)
	-- 自己场上有这张卡以外的昆虫族怪兽存在的场合，自己场上存在的昆虫族怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c74976215.condition)
	e1:SetTarget(c74976215.target)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的昆虫族怪兽
function c74976215.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 设置效果生效条件：自己场上有这张卡以外的昆虫族怪兽存在
function c74976215.condition(e)
	-- 检查自己场上是否存在至少1张除自身以外的表侧表示昆虫族怪兽
	return Duel.IsExistingMatchingCard(c74976215.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 使贯穿效果适用于自己场上的昆虫族怪兽
function c74976215.target(e,c)
	return c:IsRace(RACE_INSECT)
end
