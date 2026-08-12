--バリア・バブル
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的全部「娱乐伙伴」怪兽以及「娱乐法师」怪兽1回合各有1次不会被战斗·效果破坏。
-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的「娱乐伙伴」怪兽以及「娱乐法师」怪兽的战斗发生的对自己的战斗伤害变成0。
function c79777187.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的「娱乐伙伴」怪兽以及「娱乐法师」怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c79777187.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的全部「娱乐伙伴」怪兽以及「娱乐法师」怪兽1回合各有1次不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c79777187.target)
	e3:SetValue(c79777187.indct)
	c:RegisterEffect(e3)
end
-- 过滤出自己场上的「娱乐伙伴」怪兽以及「娱乐法师」怪兽作为效果适用对象
function c79777187.target(e,c)
	return c:IsSetCard(0xc6,0x9f)
end
-- 设置因战斗或效果破坏时，每回合各有1次不会被破坏
function c79777187.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
