--水物語－ウラシマ
-- 效果：
-- ①：自己墓地有「水伶女」怪兽存在的场合，以场上1只怪兽为对象才能发动。直到回合结束时，那只怪兽的效果无效化，攻击力·守备力变成100，不受对方的效果影响。
function c28325165.initial_effect(c)
	-- 效果发动条件：自己墓地有「水伶女」怪兽存在且在伤害步骤前才能发动，对象为场上1只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c28325165.condition)
	e1:SetTarget(c28325165.target)
	e1:SetOperation(c28325165.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为「水伶女」怪兽
function c28325165.cfilter(c)
	return c:IsSetCard(0xcd) and c:IsType(TYPE_MONSTER)
end
-- 效果发动条件判断：判断是否满足伤害步骤前发动且自己墓地有「水伶女」怪兽
function c28325165.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于伤害步骤前的时机
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 判断自己墓地是否存在至少1张「水伶女」怪兽
		and Duel.IsExistingMatchingCard(c28325165.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果处理目标选择：选择场上1只表侧表示的怪兽作为对象
function c28325165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件：场上存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将效果对象设为被选择的怪兽，用于后续处理
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理执行：对目标怪兽施加效果
function c28325165.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时解除无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 将目标怪兽的攻击力变为100
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(100)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e4)
		-- 使目标怪兽不受对方效果影响
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e5:SetRange(LOCATION_MZONE)
		e5:SetCode(EFFECT_IMMUNE_EFFECT)
		e5:SetValue(c28325165.efilter)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5)
	end
end
-- 效果适用范围判断：判断效果是否来自对方
function c28325165.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
