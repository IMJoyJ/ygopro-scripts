--神の威光
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。只要这张卡在场上存在，双方玩家不能把选择的怪兽作为卡的效果的对象。发动后第2次的自己的准备阶段时这张卡送去墓地。
function c16308000.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。只要这张卡在场上存在，双方玩家不能把选择的怪兽作为卡的效果的对象。发动后第2次的自己的准备阶段时这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER,0x1c1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16308000.target)
	e1:SetOperation(c16308000.operation)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示且名字带有「极神」字段的怪兽，作为本卡发动时可选择的对象。
function c16308000.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 发动时的取对象处理：要求选择自己场上1只表侧表示的「极神」怪兽，并在效果发动时确定该对象。
function c16308000.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16308000.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只表侧表示且名字带有「极神」的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c16308000.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张符合条件的表侧表示「极神」怪兽作为本效果的取对象。
	Duel.SelectTarget(tp,c16308000.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，为选择的怪兽附加“不能成为效果对象”的保护效果，并设置本卡在第2次自己准备阶段送去墓地的自毁效果。
function c16308000.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的取对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		-- 只要这张卡在场上存在，双方玩家不能把选择的怪兽作为卡的效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c16308000.rcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 发动后第2次的自己的准备阶段时这张卡送去墓地。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1)
		e2:SetLabel(2)
		e2:SetLabelObject(tc)
		e2:SetCondition(c16308000.tgcon)
		e2:SetOperation(c16308000.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		c:RegisterEffect(e2)
	end
end
-- 检查神之威光是否仍然以选择的怪兽为永续对象，只有持续取着该对象时，保护效果才继续适用。
function c16308000.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 判定当前回合玩家是否为这张卡的发动者，用于只在发动者的准备阶段进行自毁倒计时处理。
function c16308000.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否是效果发动者，以确保只在自己的准备阶段触发计数。
	return Duel.GetTurnPlayer()==tp
end
-- 每次自己的准备阶段将计数减1，当计数减为0且这张卡仍以选择怪兽为永续对象时，将这张卡送去墓地。
function c16308000.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 and e:GetHandler():IsHasCardTarget(e:GetLabelObject()) then
		-- 将这张卡（神之威光）因自身效果送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
