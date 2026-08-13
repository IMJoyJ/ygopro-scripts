--スペシャル・デュアル・サモン
-- 效果：
-- 选择自己场上表侧表示存在的1只二重怪兽，变成再度召唤的状态。这个回合的结束阶段时，选择的二重怪兽回到手卡。
function c26120084.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只二重怪兽，变成再度召唤的状态。这个回合的结束阶段时，选择的二重怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c26120084.target)
	e1:SetOperation(c26120084.operation)
	c:RegisterEffect(e1)
end
c26120084.has_text_type=TYPE_DUAL
-- 对象过滤条件：自己场上表侧表示的二重怪兽，且未处于再度召唤状态。
function c26120084.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
-- 发动时的取对象处理：从自己场上选择1只符合条件的二重怪兽作为效果对象。
function c26120084.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26120084.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的二重怪兽，作为效果可否发动的判定。
	if chk==0 then return Duel.IsExistingTarget(c26120084.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择效果对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的二重怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c26120084.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使对象变为再度召唤状态，并给对象注册结束阶段返回手卡的效果。
function c26120084.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c26120084.filter(tc) then
		tc:EnableDualState()
		-- 这个回合的结束阶段时，选择的二重怪兽回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(c26120084.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 结束阶段时的处理：使持有该效果的怪兽返回手卡。
function c26120084.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将那只怪兽以效果原因返回持有者的手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
