--オネスト
-- 效果：
-- ①：自己主要阶段才能发动。场上的表侧表示的这张卡回到手卡。
-- ②：自己的光属性怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升进行战斗的对方怪兽的攻击力数值。
function c37742478.initial_effect(c)
	-- ①：自己主要阶段才能发动。场上的表侧表示的这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(37742478,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c37742478.target1)
	e1:SetOperation(c37742478.operation1)
	c:RegisterEffect(e1)
	-- ②：自己的光属性怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升进行战斗的对方怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(37742478,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c37742478.condition2)
	e2:SetCost(c37742478.cost2)
	e2:SetOperation(c37742478.operation2)
	c:RegisterEffect(e2)
end
-- 发动选择阶段：若此卡能满足回到手卡的条件则允许发动，并设定将这张卡返回手卡的操作信息。
function c37742478.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本次连锁的操作信息：确定处理类别为回到手卡，对象为效果发动者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若此卡仍处于表侧表示且与发动效果保持关联，则将其送回持有者手卡。
function c37742478.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 以效果原因将这张欧尼斯特从场上送回持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 判定②效果的发动条件：当前必须处于伤害步骤且尚未进行伤害计算，并且存在进行战斗的己方光属性怪兽和对方怪兽，该己方光属性怪兽需与战斗关联。
function c37742478.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所在阶段，用于判断是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤，或已经进行了伤害计算，则不能发动（即只能在伤害计算前发动）。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得本次战斗的攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	return d~=nil and d:IsFaceup() and ((a:IsControler(tp) and a:IsAttribute(ATTRIBUTE_LIGHT) and a:IsRelateToBattle())
		or (d:IsControler(tp) and d:IsAttribute(ATTRIBUTE_LIGHT) and d:IsRelateToBattle()))
end
-- 支付代价：从手卡将这张欧尼斯特送去墓地，作为发动②效果所需的cost。
function c37742478.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以cost原因将这张欧尼斯特从手卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：根据战斗双方中哪一方是己方控制的光属性怪兽，为该怪兽赋予攻击力上升效果，数值等于对方怪兽当前攻击力，持续到回合结束。
function c37742478.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得本次战斗的攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 那只怪兽的攻击力直到回合结束时上升进行战斗的对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	if a:IsControler(tp) then
		e1:SetValue(d:GetAttack())
		a:RegisterEffect(e1)
	else
		e1:SetValue(a:GetAttack())
		d:RegisterEffect(e1)
	end
end
