--ライオ・アリゲーター
-- 效果：
-- 自己场上有这张卡以外的爬虫类族怪兽存在的场合，自己场上存在的爬虫类族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c4611269.initial_effect(c)
	-- 创建一个场地方效果，该效果为贯穿伤害效果，影响自己场上怪兽区域，条件为己方场上有除这张卡外的爬虫类族怪兽存在，目标为己方场上的爬虫类族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c4611269.condition)
	e1:SetTarget(c4611269.target)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为表侧表示的爬虫类族怪兽
function c4611269.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 效果条件函数，检查自己场上是否存在除这张卡以外的爬虫类族怪兽
function c4611269.condition(e)
	-- 检索满足条件的卡片组，即己方场上存在至少1张除这张卡外的爬虫类族怪兽
	return Duel.IsExistingMatchingCard(c4611269.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果目标函数，设定效果影响的怪兽必须为爬虫类族
function c4611269.target(e,c)
	return c:IsRace(RACE_REPTILE)
end
