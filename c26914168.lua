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
-- 检查效果是否可以发动，判断当前控制的怪兽是否能回到手牌
function c26914168.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将要将该卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果，将该卡送回手牌
function c26914168.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将该卡送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 判断是否满足发动条件，确保当前处于伤害步骤且未计算战斗伤害
function c26914168.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local phase=Duel.GetCurrentPhase()
	-- 如果当前阶段不是伤害步骤或伤害已计算，则效果不发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsControler(tp) and a:IsFaceup() and a:IsAttribute(ATTRIBUTE_DARK) and d:IsControler(1-tp) and d:IsFaceup() and d:IsRelateToBattle()
end
-- 检查是否满足发动条件，判断手牌是否能送去墓地作为代价
function c26914168.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将该卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果目标，将攻击目标怪兽设为效果目标
function c26914168.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	if chk==0 then return d end
	-- 设置连锁操作信息，表示将要改变目标怪兽的攻击力
	Duel.SetTargetCard(d)
end
-- 执行效果，为攻击目标怪兽添加攻击力下降效果
function c26914168.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local d=Duel.GetFirstTarget()
	if not (d:IsRelateToBattle() and d:IsFaceup() and d:IsControler(1-tp)) then return end
	-- 为攻击目标怪兽添加攻击力下降效果，下降值等于自身攻击力
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(-d:GetAttack())
	d:RegisterEffect(e1)
end
