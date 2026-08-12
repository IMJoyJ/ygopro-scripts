--グラヴィティ・バインド－超重力の網－
-- 效果：
-- 场上的4星以上的怪兽不能攻击。
function c85742772.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上的4星以上的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c85742772.atktarget)
	c:RegisterEffect(e2)
end
-- 过滤出等级在4星以上的怪兽作为不能攻击的对象
function c85742772.atktarget(e,c)
	return c:IsLevelAbove(4)
end
