--フレイム・アドミニスター
-- 效果：
-- 电子界族怪兽2只
-- ①：「炎上框架管理员」在自己场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，自己场上的连接怪兽的攻击力上升800。
function c49847524.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,49847524)
	-- 为卡片添加连接召唤手续，要求使用2只电子界族连接素材进行连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- 只要这张卡在怪兽区域存在，自己场上的连接怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有连接怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_LINK))
	e1:SetValue(800)
	c:RegisterEffect(e1)
end
