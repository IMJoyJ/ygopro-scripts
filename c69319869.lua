--鈍重
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降那只怪兽的守备力数值。
function c69319869.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降那只怪兽的守备力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件：在伤害步骤中，只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c69319869.target)
	e1:SetOperation(c69319869.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与合法性检测函数。
function c69319869.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 进行对象重选时的合法性检测，检查该卡是否仍在怪兽区且为守备力大于0的表侧表示怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.nzdef(chkc) end
	-- 在发动效果时，检查场上是否存在至少1只守备力大于0的表侧表示怪兽作为合法的效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.nzdef,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只守备力大于0的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,aux.nzdef,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理（发动）函数，用于降低目标怪兽的攻击力。
function c69319869.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时下降那只怪兽的守备力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetDefense()*-1)
		tc:RegisterEffect(e1)
	end
end
