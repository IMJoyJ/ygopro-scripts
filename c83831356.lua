--カラクリ大暴走
-- 效果：
-- 选择场上表侧表示存在的1只名字带有「机巧」的怪兽发动。直到结束阶段时，选择的怪兽的攻击力上升1000，效果无效化。
function c83831356.initial_effect(c)
	-- 选择场上表侧表示存在的1只名字带有「机巧」的怪兽发动。直到结束阶段时，选择的怪兽的攻击力上升1000，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置发动条件：在伤害步骤中，仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c83831356.target)
	e1:SetOperation(c83831356.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且名字带有「机巧」的怪兽
function c83831356.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11)
end
-- 效果发动的目标选择与检测函数
function c83831356.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83831356.filter(chkc) end
	-- 在发动准备阶段，检测场上是否存在符合条件的可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c83831356.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的名字带有「机巧」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83831356.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示该效果包含使卡片效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理的执行函数
function c83831356.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到结束阶段时，选择的怪兽的攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
