--ミョルニルの魔槌
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
function c89914395.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果的发动条件为：当前处于可以进入战斗阶段或正处于战斗阶段的时点。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c89914395.target)
	e1:SetOperation(c89914395.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、名字带有「极神」且当前未拥有增加攻击次数效果的怪兽。
function c89914395.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果发动时的目标选择处理，确认并选择自己场上1只表侧表示的「极神」怪兽作为效果对象。
function c89914395.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89914395.filter(chkc) end
	-- 在发动阶段的第0步，检查自己场上是否存在至少1只符合条件的「极神」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c89914395.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家发送提示信息，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「极神」怪兽作为效果的对象。
	Duel.SelectTarget(tp,c89914395.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使选中的「极神」怪兽在这个回合的同1次战斗阶段中可以作2次攻击。
function c89914395.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
