--強者の苦痛
-- 效果：
-- ①：对方场上的怪兽的攻击力下降那怪兽的等级×100。
function c44947065.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力下降那怪兽的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c44947065.val)
	c:RegisterEffect(e2)
end
-- 设置效果值为目标怪兽等级乘以负100，用于降低其攻击力
function c44947065.val(e,c)
	return c:GetLevel()*-100
end
