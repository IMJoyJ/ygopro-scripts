--暴走闘君
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，攻击表示的衍生物攻击力上升1000，不会被战斗破坏。
function c14342283.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，攻击表示的衍生物攻击力上升1000，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- 攻击表示的衍生物攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c14342283.tg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 攻击表示的衍生物不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c14342283.tg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判定目标是否为攻击表示的衍生物
function c14342283.tg(e,c)
	return c:IsType(TYPE_TOKEN) and c:IsAttackPos()
end
