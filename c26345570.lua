--先史遺産－ピラミッド・アイ・タブレット
-- 效果：
-- 自己场上的名字带有「先史遗产」的怪兽的攻击力上升800。
function c26345570.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的名字带有「先史遗产」的怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为名字带有「先史遗产」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x70))
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
