--ダーク・オネスト
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。场上的表侧表示的这张卡回到持有者手卡。
-- ②：自己的暗属性怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降那自身攻击力数值。
function c26914168.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。场上的表侧表示的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26914168,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c26914168.target1)
	e1:SetOperation(c26914168.operation1)
	c:RegisterEffect(e1)
	-- ②：自己的暗属性怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降那自身攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26914168,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(c26914168.condition2)
	e2:SetCost(c26914168.cost2)
	e2:SetTarget(c26914168.target2)
	e2:SetOperation(c26914168.operation2)
	c:RegisterEffect(e2)
end
-- ①效果发动时的合法性判定：确认这张卡能否回手牌，并设置回手牌的操作信息。
function c26914168.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡以效果送回持有者手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍表侧在场且与发动时的效果关联，则将其送回持有者手牌。
function c26914168.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡送回持有者手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- ②效果发动条件：当前处于伤害步骤且尚未进行伤害计算，存在战斗双方怪兽；将攻击方视为己方怪兽，若攻击方不是己方则交换攻守对象；要求己方怪兽为表侧暗属性，对方怪兽表侧且与战斗关联，并记录对方怪兽。
function c26914168.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤或伤害计算已经完成，则不满足发动条件。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击对象怪兽；若不存在攻击对象则条件不成立。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsControler(tp) and a:IsFaceup() and a:IsAttribute(ATTRIBUTE_DARK) and d:IsControler(1-tp) and d:IsFaceup() and d:IsRelateToBattle()
end
-- ②效果发动代价：确认手卡的这张卡能否作为代价送墓，并执行送墓。
function c26914168.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡的这张卡送入墓地，作为发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果选择对象：以条件记录中与己方暗属性怪兽战斗的那只对方怪兽作为效果对象。
function c26914168.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	if chk==0 then return d end
	-- 将该对方怪兽设置为当前连锁的处理对象。
	Duel.SetTargetCard(d)
end
-- ②效果处理：若对象怪兽仍与战斗关联且表侧表示在对方场上存在，则给予其攻击力下降效果。
function c26914168.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果处理的对象怪兽。
	local d=Duel.GetFirstTarget()
	if not (d:IsRelateToBattle() and d:IsFaceup() and d:IsControler(1-tp)) then return end
	-- 那只对方怪兽的攻击力直到回合结束时下降那自身攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(-d:GetAttack())
	d:RegisterEffect(e1)
end
