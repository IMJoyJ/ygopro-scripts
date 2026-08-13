--ニードル・ギルマン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的鱼族·海龙族·水族怪兽的攻击力上升400。
function c42463414.initial_effect(c)
	-- 对应效果原文中的①：只要这张卡在怪兽区域存在，自己场上的鱼族·海龙族·水族怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c42463414.atktg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
-- 作为攻击力增减效果的过滤条件：判断场上怪兽是否属于鱼族·海龙族·水族，符合条件时该怪兽的攻击力上升400。
function c42463414.atktg(e,c)
	return c:IsRace(0x60040)
end
