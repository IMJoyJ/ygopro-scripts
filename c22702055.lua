--海
-- 效果：
-- 全部鱼族·海龙族·雷族·水族的怪兽攻击力·守备力上升200。机械族·炎族的怪兽攻击力·守备力下降200。
function c22702055.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 全部鱼族·海龙族·雷族·水族的怪兽攻击力·守备力上升200。机械族·炎族的怪兽攻击力·守备力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c22702055.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为鱼族·海龙族·雷族·水族，是则返回200，否则判断是否为机械族·炎族，是则返回-200，否则返回0
function c22702055.val(e,c)
	local r=c:GetRace()
	if bit.band(r,RACE_FISH+RACE_SEASERPENT+RACE_THUNDER+RACE_AQUA)>0 then return 200
	elseif bit.band(r,RACE_MACHINE+RACE_PYRO)>0 then return -200
	else return 0 end
end
