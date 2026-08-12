--神聖なる森
-- 效果：
-- 自己场上表侧表示存在的植物族·兽族·兽战士族怪兽1回合只有1次不会被战斗破坏。这个效果1回合只能适用1次。
function c69112325.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的植物族·兽族·兽战士族怪兽1回合只有1次不会被战斗破坏。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c69112325.indtg)
	e2:SetCountLimit(1)
	e2:SetValue(c69112325.valcon)
	c:RegisterEffect(e2)
end
-- 过滤出自己场上表侧表示存在的植物族、兽族、兽战士族怪兽作为效果适用对象
function c69112325.indtg(e,c)
	return c:IsRace(RACE_PLANT+RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 设定不会被破坏的原因仅限于战斗破坏
function c69112325.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
