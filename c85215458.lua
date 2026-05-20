--BF－月影のカルート
-- 效果：
-- ①：自己的「黑羽」怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升1400。
function c85215458.initial_effect(c)
	-- ①：自己的「黑羽」怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升1400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(85215458,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c85215458.condition)
	e1:SetCost(c85215458.cost)
	e1:SetOperation(c85215458.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：是否处于伤害步骤开始时到伤害计算前，且己方有「黑羽」怪兽进行战斗
function c85215458.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 如果不是伤害步骤，或者已经进行了伤害计算，则不能发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsSetCard(0x33) and a:IsRelateToBattle())
		or (d and d:IsControler(tp) and d:IsSetCard(0x33) and d:IsRelateToBattle())
end
-- 检查并执行发动代价：把这张卡从手卡送去墓地
function c85215458.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 执行效果：使进行战斗的己方「黑羽」怪兽攻击力直到回合结束时上升1400
function c85215458.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 如果当前不是自己的回合，则将目标怪兽指向被攻击的怪兽（即己方的防御怪兽）
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 那只怪兽的攻击力直到回合结束时上升1400。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1400)
	a:RegisterEffect(e1)
end
