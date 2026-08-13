--バウンサー・ガード
-- 效果：
-- 选择自己场上1只名字带有「保镖」的怪兽才能发动。这个回合，选择的怪兽不会成为卡的效果的对象，不会被战斗破坏。这个回合，对方怪兽攻击的场合，必须把选择的怪兽作为攻击对象。
function c48582558.initial_effect(c)
	-- 选择自己场上1只名字带有「保镖」的怪兽才能发动。这个回合，选择的怪兽不会成为卡的效果的对象，不会被战斗破坏。这个回合，对方怪兽攻击的场合，必须把选择的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48582558.target)
	e1:SetOperation(c48582558.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且卡名含有「保镖」字段的怪兽。
function c48582558.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6b)
end
-- 发动时的取对象处理：检查是否满足发动条件，若满足则提示玩家选择自己场上1只表侧表示的名字带有「保镖」的怪兽作为对象。
function c48582558.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48582558.filter(chkc) end
	-- 发动条件判定：确认自己场上是否存在至少1只表侧表示且名字带有「保镖」的怪兽，若存在则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c48582558.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，要求选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示且名字带有「保镖」的怪兽作为效果的对象。
	Duel.SelectTarget(tp,c48582558.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍然表侧表示且与发动效果关联，则使其本回合不会被战斗破坏、不会成为卡的效果对象，并令对方怪兽本回合攻击时必须选择该怪兽为攻击对象。
function c48582558.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，选择的怪兽不会成为卡的效果的对象。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local fid=tc:GetRealFieldID()
		-- 这个回合，对方怪兽攻击的场合，必须把选择的怪兽作为攻击对象。
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e4:SetTargetRange(0,LOCATION_MZONE)
		e4:SetValue(c48582558.atklimit)
		e4:SetLabel(fid)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 将上述“必须攻击对象”的永续效果注册到场上，持续到本回合结束阶段。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 判定正在攻击的怪兽是否为被选择的那只怪兽：通过比对怪兽的真实场地编号和效果记录的标签值。
function c48582558.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
