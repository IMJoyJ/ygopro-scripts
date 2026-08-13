--ライオ・アリゲーター
-- 效果：
-- 自己场上有这张卡以外的爬虫类族怪兽存在的场合，自己场上存在的爬虫类族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c4611269.initial_effect(c)
	-- 自己场上有这张卡以外的爬虫类族怪兽存在的场合，自己场上存在的爬虫类族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c4611269.condition)
	e1:SetTarget(c4611269.target)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡片为表侧表示且种族为爬虫类族，用于筛选符合条件的爬虫类族怪兽。
function c4611269.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 效果条件：自己场上有这张卡以外的表侧表示爬虫类族怪兽存在时才适用贯穿伤害。
function c4611269.condition(e)
	-- 检查自己场上是否存在至少1张满足 cfilter 条件且除外自身（这张卡）的爬虫类族怪兽。
	return Duel.IsExistingMatchingCard(c4611269.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 贯穿效果的适用对象筛选：只有爬虫类族怪兽才能获得贯穿伤害效果。
function c4611269.target(e,c)
	return c:IsRace(RACE_REPTILE)
end
