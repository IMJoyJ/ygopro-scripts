--ランスフォリンクス
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己的通常怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽描述】
-- 太古灭绝之下幸存的梦幻翼龙。它的模样进化得更有攻击性，尖喙化成了贯穿一切的长枪。尽管如此主食好像还是吃鱼。
function c48940337.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 设置目标为场上所有通常怪兽，用于触发贯穿伤害效果
function c48940337.target(e,c)
	return c:IsType(TYPE_NORMAL)
end
