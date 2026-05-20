--超古代生物の墓場
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的6星以上的怪兽不能攻击宣言，双方不能把那些效果发动。
function c83266092.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x28)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，特殊召唤的6星以上的怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c83266092.target)
	c:RegisterEffect(e2)
	-- 双方不能把那些效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c83266092.target)
	c:RegisterEffect(e3)
end
-- 过滤出等级6以上且是特殊召唤的怪兽作为效果影响对象
function c83266092.target(e,c)
	return c:IsLevelAbove(6) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
