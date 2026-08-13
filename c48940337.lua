--ランスフォリンクス
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己的通常怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽描述】
-- 太古灭绝之下幸存的梦幻翼龙。它的模样进化得更有攻击性，尖喙化成了贯穿一切的长枪。尽管如此主食好像还是吃鱼。
function c48940337.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆怪兽属性，使其作为灵摆卡可在灵摆区发动，并获得灵摆召唤的资格。
	aux.EnablePendulumAttribute(c)
	-- ①：自己的通常怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c48940337.target)
	c:RegisterEffect(e2)
end
-- 贯穿效果的适用对象判定：检查战斗的怪兽是否为通常怪兽，以限定只让己方场上的通常怪兽获得贯穿战斗伤害。
function c48940337.target(e,c)
	return c:IsType(TYPE_NORMAL)
end
