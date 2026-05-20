--毒蛇の牙
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的守备力直到结束阶段时下降500。
function c596051.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的守备力直到结束阶段时下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件，限制该效果只能在非伤害阶段或伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c596051.target)
	e1:SetOperation(c596051.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向处理，用于判定并选择场上1只表侧表示的怪兽作为对象
function c596051.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动准备阶段，判定双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择双方场上表侧表示的1只怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，使作为对象的怪兽守备力下降500点直到结束阶段
function c596051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的守备力直到结束阶段时下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
