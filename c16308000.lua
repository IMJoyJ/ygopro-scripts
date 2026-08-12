--神の威光
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。只要这张卡在场上存在，双方玩家不能把选择的怪兽作为卡的效果的对象。发动后第2次的自己的准备阶段时这张卡送去墓地。
function c16308000.initial_effect(c)
	-- 效果发动，设置为自由连锁时点，提示时点为怪兽正面上场，设置为取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER,0x1c1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16308000.target)
	e1:SetOperation(c16308000.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且种族为「极神」的怪兽
function c16308000.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽作为效果对象
function c16308000.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16308000.filter(chkc) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c16308000.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c16308000.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，设置对象怪兽不能成为效果对象，并设置2次准备阶段后将此卡送去墓地
function c16308000.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		-- 使选择的怪兽不能成为卡的效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c16308000.rcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 设置一个回合结束后触发的效果，用于在第2次准备阶段时将此卡送去墓地
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
-- 条件函数：当此卡被选择为对象时生效
function c16308000.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 条件函数：判断是否为自己的准备阶段
function c16308000.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发效果的处理函数，计数器减1，当计数器归零时将此卡送去墓地
function c16308000.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 and e:GetHandler():IsHasCardTarget(e:GetLabelObject()) then
		-- 将此卡以效果原因送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
