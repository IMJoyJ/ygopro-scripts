--ウミノタウルス
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上的鱼族·海龙族·水族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c30464153.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上的鱼族·海龙族·水族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c30464153.target)
	c:RegisterEffect(e1)
end
-- 贯穿伤害效果的过滤函数，用于判定场上表侧表示存在的这张卡所影响的己方怪兽是否为鱼族、海龙族或水族怪兽；若满足该种族条件，则其攻击守备表示怪兽时发动贯穿战斗伤害。
function c30464153.target(e,c)
	return c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
