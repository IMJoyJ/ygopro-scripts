--荒野
-- 效果：
-- 全部恐龙族·不死族·岩石族的怪兽攻击力·守备力上升200。
function c23424603.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：全部恐龙族·不死族·岩石族的怪兽攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果适用对象：持有恐龙族、不死族或岩石族其中之一的场上怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DINOSAUR+RACE_ZOMBIE+RACE_ROCK))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
