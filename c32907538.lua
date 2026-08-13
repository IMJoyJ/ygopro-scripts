--ウォールクリエイター
-- 效果：
-- 这张卡召唤成功时，可以选择对方场上存在的1只怪兽。只要这张卡在场上表侧表示存在，选择的怪兽不能攻击也不能解放。这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。
function c32907538.initial_effect(c)
	-- 这张卡召唤成功时，可以选择对方场上存在的1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32907538,1))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c32907538.target)
	e1:SetOperation(c32907538.operation)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32907538.mtcon)
	e2:SetOperation(c32907538.mtop)
	c:RegisterEffect(e2)
end
-- 召唤成功时的诱发选发效果的目标处理：首先判断连锁处理时是否在核对对象（chkc），若是则要求对象为对方场上的怪兽；在发动时点（chk==0）检查对方场上是否存在至少1只可选怪兽；随后提示玩家选择对象并选定对方场上1只怪兽作为效果对象。
function c32907538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在效果发动时点检查对方场上是否存在至少1只满足条件的怪兽（即能够成为效果对象的对方场上怪兽）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择对象的提示消息，告知玩家正在选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让控制者从对方场上选择1只怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，若这张卡仍与效果关联、所选对象仍表侧表示且与效果关联，且对象不免疫此效果，则将对象设置为这张卡的永续对象，并给对象赋予不能攻击、不能作为上级召唤的解放、不能作为上级召唤以外的解放的效果。
function c32907538.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时当前连锁选择的怪兽（即发动时选择的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 只要这张卡在场上表侧表示存在，选择的怪兽不能攻击也不能解放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c32907538.rcon)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e3)
	end
end
-- 该效果的适用条件：以效果拥有者（造墙者）是否仍将效果持有卡（被限制的怪兽）作为永续对象来判断，若造墙者不再以该怪兽为对象则效果不适用。
function c32907538.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 维持费用的效果条件：仅在造墙者的控制者的结束阶段（当前回合玩家等于控制者）时才处理。
function c32907538.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否就是这张卡的控制者，即是否是自己回合的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段时的维持处理：若控制者能够支付500基本分并选择支付，则支付500基本分；否则不支付并破坏这张卡。
function c32907538.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 先检查控制者是否有足够支付500基本分的LP，并弹出是否支付500基本分维持造墙者的选择。
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(32907538,0)) then  --"是否要支付500基本分维持「造墙者」？"
		-- 支付500基本分作为维持造墙者的费用。
		Duel.PayLPCost(tp,500)
	else
		-- 当控制者不支付维持费用时，以代价（REASON_COST）的方式破坏这张卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
