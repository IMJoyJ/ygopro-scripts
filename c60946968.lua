--異界空間－Aゾーン
-- 效果：
-- 对方怪兽和自己场上存在的名字带有「外星」的怪兽战斗的场合，对方怪兽的攻击力·守备力只在伤害计算时下降300。
function c60946968.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽和自己场上存在的名字带有「外星」的怪兽战斗的场合，对方怪兽的攻击力只在伤害计算时下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c60946968.adcon)
	e2:SetTarget(c60946968.adtg)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 判断是否满足「对方怪兽和自己场上的『外星』怪兽进行战斗，且处于伤害计算时」的条件
function c60946968.adcon(e)
	-- 如果当前阶段不是伤害计算时，则不满足条件
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	-- 获取本次战斗的攻击目标（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	if not d then return false end
	local tp=e:GetHandlerPlayer()
	-- 如果攻击目标是对方怪兽，则将我方怪兽变量设为攻击发起者（确保d代表我方场上的怪兽）
	if d:IsControler(1-tp) then d=Duel.GetAttacker() end
	return d:IsSetCard(0xc)
end
-- 确定受影响的卡片范围为参与本次战斗的怪兽
function c60946968.adtg(e,c)
	-- 如果卡片是当前的攻击怪兽或被攻击怪兽，则适用该效果
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
