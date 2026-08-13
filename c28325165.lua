--水物語－ウラシマ
-- 效果：
-- ①：自己墓地有「水伶女」怪兽存在的场合，以场上1只怪兽为对象才能发动。直到回合结束时，那只怪兽的效果无效化，攻击力·守备力变成100，不受对方的效果影响。
function c28325165.initial_effect(c)
	-- ①：自己墓地有「水伶女」怪兽存在的场合，以场上1只怪兽为对象才能发动。直到回合结束时，那只怪兽的效果无效化，攻击力·守备力变成100，不受对方的效果影响。
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
-- 筛选满足『水伶女』字段且为怪兽卡的卡，用于检查自己墓地是否存在符合条件的「水伶女」怪兽。
function c28325165.cfilter(c)
	return c:IsSetCard(0xcd) and c:IsType(TYPE_MONSTER)
end
-- 发动条件：满足伤害步骤限制（伤害计算前），并且自己墓地存在1只以上「水伶女」怪兽。
function c28325165.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 限制只能在伤害步骤的伤害计算前发动（即伤害步骤内若已进行伤害计算则不能发动）。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 检查自己墓地是否存在至少1只满足cfilter（「水伶女」怪兽）的卡。
		and Duel.IsExistingMatchingCard(c28325165.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果发动时的取对象处理：选择双方场上1只表侧表示怪兽作为效果对象，并登记无效效果的分类信息。
function c28325165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动时确认场上是否存在1只以上可作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方场上选择1只表侧表示怪兽作为效果对象，并注册为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁将执行『效果无效化』（CATEGORY_DISABLE）的操作信息，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：对象怪兽仍与效果相关且表侧表示时，将其相关连锁无效，并赋予『效果无效化』『攻击力·守备力变成100』『不受对方效果影响』，持续到回合结束。
function c28325165.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使对象怪兽相关的连锁效果无效化（若其发动中则将其无效），并在变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 攻击力·守备力变成100
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(100)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e4)
		-- 不受对方的效果影响
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
-- 免疫效果的判定函数：若效果来源的玩家不是这张卡的持有者（即对方发动的效果），则返回真，使该效果无效。
function c28325165.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
