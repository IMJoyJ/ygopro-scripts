--黄金の歯車装置箱
-- 效果：
-- 选择场上表侧表示存在的1只名字带有「机巧」的怪兽发动。直到结束阶段时，选择的怪兽的攻击力上升500，守备力上升1500。
function c59156966.initial_effect(c)
	-- 选择场上表侧表示存在的1只名字带有「机巧」的怪兽发动。直到结束阶段时，选择的怪兽的攻击力上升500，守备力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前（限制不能在伤害计算后发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c59156966.target)
	e1:SetOperation(c59156966.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且名字带有「机巧」的怪兽
function c59156966.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11)
end
-- 效果发动时的目标选择与合法性检测
function c59156966.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c59156966.filter(chkc) end
	-- 在发动时，检查场上是否存在至少1只符合条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c59156966.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59156966.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理的执行函数，使目标怪兽的攻防上升
function c59156966.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到结束阶段时，选择的怪兽的攻击力上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		-- 直到结束阶段时，选择的怪兽的守备力上升1500
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1500)
		tc:RegisterEffect(e2)
	end
end
