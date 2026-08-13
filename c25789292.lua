--禁じられた聖杯
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升400，效果无效化。
function c25789292.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升400，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果发动条件为aux.dscon，即效果只能在非伤害步骤或伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c25789292.target)
	e1:SetOperation(c25789292.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动时的目标选择函数：检查能否选择对象、提示选择并选择场上1只表侧表示怪兽，同时登记操作信息。
function c25789292.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动合法性检查（chk==0）时，确认双方场上存在至少1只表侧表示怪兽且能被选为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从双方场上选择1只表侧表示怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，登记本次效果包含“无效化”分类，对象为所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 定义效果处理时的操作函数：获取对象怪兽后，对其适用攻击力上升400和效果无效化的处理，持续到回合结束。
function c25789292.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与对象怪兽相关的连锁效果无效化，并以变里侧表示作为重置条件。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽直到回合结束时攻击力上升400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(400)
		tc:RegisterEffect(e1)
		-- 那只怪兽直到回合结束时效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那只怪兽直到回合结束时效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
