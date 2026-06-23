--山
-- 效果：
-- 全部龙族·鸟兽族·雷族的怪兽攻击力·守备力上升200。
function c50913601.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 全部龙族·鸟兽族·雷族的怪兽攻击力·守备力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为同时具有龙族、鸟兽族、雷族属性的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON+RACE_WINDBEAST+RACE_THUNDER))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(200)
	c:RegisterEffect(e3)
end
