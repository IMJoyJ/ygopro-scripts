--武神器－ツムガリ
-- 效果：
-- 「武神器-都牟刈」的效果1回合只能使用1次。
-- ①：自己的兽战士族「武神」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把墓地的这张卡除外才能发动。那只进行战斗的自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值，那次战斗给与对方的战斗伤害变成一半。
function c56574543.initial_effect(c)
	-- ①：自己的兽战士族「武神」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把墓地的这张卡除外才能发动。那只进行战斗的自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值，那次战斗给与对方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56574543,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,56574543)
	e1:SetCondition(c56574543.atkcon)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c56574543.atkop)
	c:RegisterEffect(e1)
end
-- 检查是否在伤害步骤开始时到伤害计算前，且自己场上有兽战士族的「武神」怪兽正在与对方怪兽进行战斗
function c56574543.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 过滤非伤害步骤的时点，且必须在伤害计算前
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取此次战斗的被攻击怪兽
	local c=Duel.GetAttackTarget()
	if not c then return false end
	-- 确定己方进行战斗的怪兽（如果是对方被攻击，则己方是攻击方）
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	return c and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsRelateToBattle()
end
-- 执行效果：使进行战斗的自己怪兽攻击力上升对方怪兽的攻击力数值，并使这次战斗给对方造成的战斗伤害减半
function c56574543.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or a:IsFacedown() or not d:IsRelateToBattle() or d:IsFacedown() then return end
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsImmuneToEffect(e) then return end
	-- 那只进行战斗的自己怪兽的攻击力直到伤害步骤结束时上升进行战斗的对方怪兽的攻击力数值
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(d:GetAttack())
	a:RegisterEffect(e1)
	-- 那次战斗给与对方的战斗伤害变成一半。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将减半战斗伤害的效果注册给玩家，使其在本次战斗中生效
	Duel.RegisterEffect(e2,tp)
end
