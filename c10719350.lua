--炎舞－「天枢」
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只兽战士族怪兽召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的兽战士族怪兽的攻击力上升100。
function c10719350.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只兽战士族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10719350,0))  --"使用「炎舞-「天枢」」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为兽战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的兽战士族怪兽的攻击力上升100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为兽战士族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e3:SetValue(100)
	c:RegisterEffect(e3)
end
