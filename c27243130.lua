--禁じられた聖槍
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力下降800，不受其他的魔法·陷阱卡的效果影响。
function c27243130.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力下降800，不受其他的魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置该魔法卡只能在伤害步骤且尚未进行伤害计算时发动（因为①效果可在伤害步骤发动，且要遵守伤害步骤内只能在伤害计算前发动的规则）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c27243130.target)
	e1:SetOperation(c27243130.activate)
	c:RegisterEffect(e1)
end
-- 定义发动时点的目标选择处理：若为指定对象则检查该对象是否为场上表侧表示怪兽；若为发动合法性判定则检查场上是否存在至少1只表侧表示怪兽；随后提示并选择1只表侧表示怪兽作为对象。
function c27243130.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动的合法性检查：确认场上存在至少1只表侧表示怪兽可供选择作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽，并将其锁定为这张卡效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理时的操作：获取对象怪兽，若对象仍与效果相关且为表侧表示，则对那只怪兽赋予攻击力下降800和免疫其他魔法·陷阱卡效果的两个效果。
function c27243130.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时攻击力下降800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-800)
		tc:RegisterEffect(e1)
		-- 那只怪兽不受其他的魔法·陷阱卡的效果影响。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c27243130.efilter)
		tc:RegisterEffect(e2)
	end
end
-- 免疫判定条件：对方发动的魔法·陷阱卡效果（即效果类型为魔法或陷阱，且效果持有者与圣枪控制者不同）不适用。注意这里通过“其他”排除了圣枪自身的效果。
function c27243130.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
