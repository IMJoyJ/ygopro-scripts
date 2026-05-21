--怨霊の湿地帯
-- 效果：
-- 全场怪兽召唤·反转召唤·特殊召唤的那个回合不能攻击。
function c95220856.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 全场怪兽召唤·反转召唤·特殊召唤的那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c95220856.target)
	c:RegisterEffect(e2)
end
-- 过滤出在本回合召唤、反转召唤或特殊召唤过的怪兽
function c95220856.target(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
