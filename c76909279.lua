--激昂のミノタウルス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的兽族·兽战士族·鸟兽族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c76909279.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的兽族·兽战士族·鸟兽族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c76909279.target)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为兽族、兽战士族或鸟兽族，以确定是否适用贯穿效果
function c76909279.target(e,c)
	return c:IsRace(RACE_BEASTWARRIOR+RACE_WINDBEAST+RACE_BEAST)
end
