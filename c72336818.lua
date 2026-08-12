--ペンテスタッグ
-- 效果：
-- 效果怪兽2只
-- ①：只要这张卡在怪兽区域存在，连接状态的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c72336818.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只效果怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- ①：只要这张卡在怪兽区域存在，连接状态的自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿效果的适用对象为处于连接状态的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLinkState))
	c:RegisterEffect(e1)
end
