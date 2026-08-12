--極星宝メギンギョルズ
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」或「极星」的怪兽发动。直到结束阶段时为止，那只怪兽的攻击力·守备力变成原本攻击力·守备力的两倍。这个回合被选择的怪兽不能直接攻击对方玩家。
function c86827882.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「极神」或「极星」的怪兽发动。直到结束阶段时为止，那只怪兽的攻击力·守备力变成原本攻击力·守备力的两倍。这个回合被选择的怪兽不能直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前（限制在伤害计算后不能发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c86827882.target)
	e1:SetOperation(c86827882.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的名字带有「极神」或「极星」的怪兽
function c86827882.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x42,0x4b)
end
-- 效果发动的对象选择与合法性检查，在伤害步骤直接攻击时需排除当前攻击怪兽
function c86827882.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86827882.filter(chkc) end
	local exc=nil
	-- 若在伤害步骤且为直接攻击，则将攻击怪兽设为排除对象（因为不能直接攻击的怪兽在伤害步骤不能发动此卡）
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.GetAttackTarget()==nil then exc=Duel.GetAttacker() end
	-- 在第1阶段，检查场上是否存在符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c86827882.filter,tp,LOCATION_MZONE,0,1,exc) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「极神」或「极星」怪兽作为效果对象
	Duel.SelectTarget(tp,c86827882.filter,tp,LOCATION_MZONE,0,1,1,exc)
end
-- 效果处理：使选择的怪兽攻防变成原本数值的两倍，且本回合不能直接攻击
function c86827882.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到结束阶段时为止，那只怪兽的攻击力...变成原本攻击力...的两倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack()*2)
		tc:RegisterEffect(e1)
		-- 直到结束阶段时为止，那只怪兽的...守备力变成原本...守备力的两倍。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e2)
		-- 这个回合被选择的怪兽不能直接攻击对方玩家。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
