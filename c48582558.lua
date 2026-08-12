--バウンサー・ガード
-- 效果：
-- 选择自己场上1只名字带有「保镖」的怪兽才能发动。这个回合，选择的怪兽不会成为卡的效果的对象，不会被战斗破坏。这个回合，对方怪兽攻击的场合，必须把选择的怪兽作为攻击对象。
function c48582558.initial_effect(c)
	-- 创建并注册卡的效果，使该卡可以发动，具有取对象效果，并在自由时点发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48582558.target)
	e1:SetOperation(c48582558.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查目标是否为表侧表示且名字带有「保镖」
function c48582558.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6b)
end
-- 选择目标函数：选择自己场上1只名字带有「保镖」的怪兽作为效果对象
function c48582558.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48582558.filter(chkc) end
	-- 判断是否满足发动条件：确认场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c48582558.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标：显示“请选择表侧表示的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行选择操作：从自己场上选择1只名字带有「保镖」的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c48582558.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果函数：对选中的怪兽施加效果，使其不会被战斗破坏、不会成为效果对象，并在对方攻击时必须攻击该怪兽
function c48582558.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，选择的怪兽不会成为卡的效果的对象
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local fid=tc:GetRealFieldID()
		-- 这个回合，对方怪兽攻击的场合，必须把选择的怪兽作为攻击对象
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e4:SetTargetRange(0,LOCATION_MZONE)
		e4:SetValue(c48582558.atklimit)
		e4:SetLabel(fid)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到全局环境中，使该效果在指定玩家的场上生效
		Duel.RegisterEffect(e4,tp)
	end
end
-- 判断是否为被选中的目标怪兽：通过FieldID匹配来确定是否是当前效果的目标
function c48582558.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
