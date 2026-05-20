--レベル制限A地区
-- 效果：
-- 场上表侧表示存在的3星以下怪兽全部变成攻击表示。
function c54976796.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的3星以下怪兽全部变成攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c54976796.target)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示且等级在3星以下的怪兽作为效果影响对象
function c54976796.target(e,c)
	return c:IsLevelBelow(3) and c:IsFaceup()
end
