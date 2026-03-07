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
-- 检查效果发动时是否满足条件，即该卡能否被送至手牌
function c37742478.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示该效果将把目标卡送至手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果处理，将该卡送至手牌
function c37742478.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将该卡以效果原因送至手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件，即是否处于伤害步骤且未计算伤害，且参与战斗的光属性怪兽存在
function c37742478.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或伤害已计算，则效果不满足发动条件
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	return d~=nil and d:IsFaceup() and ((a:IsControler(tp) and a:IsAttribute(ATTRIBUTE_LIGHT) and a:IsRelateToBattle())
		or (d:IsControler(tp) and d:IsAttribute(ATTRIBUTE_LIGHT) and d:IsRelateToBattle()))
end
-- 检查发动效果时是否满足条件，即该卡能否被送至墓地作为代价
function c37742478.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将该卡以代价原因送至墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 执行效果处理，使光属性怪兽攻击力上升
function c37742478.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 为攻击怪兽添加攻击力提升效果，提升数值等于对方怪兽的攻击力
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
