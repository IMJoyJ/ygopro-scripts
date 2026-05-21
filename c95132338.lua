--アクアの合唱
-- 效果：
-- ①：场上有同名怪兽存在的场上的怪兽的攻击力·守备力上升500。
function c95132338.initial_effect(c)
	-- ①：场上有同名怪兽存在的场上的怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件，限制该效果不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：场上有同名怪兽存在的场上的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c95132338.target)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤条件：筛选场上表侧表示且卡名与指定卡名相同的怪兽
function c95132338.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 确定效果适用对象：筛选出场上存在同名怪兽的表侧表示怪兽
function c95132338.target(e,c)
	-- 检查双方场上是否存在至少1张与当前怪兽同名且非自身的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c95132338.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
