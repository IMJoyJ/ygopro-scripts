--竜星の凶暴化
-- 效果：
-- ①：自己的「龙星」怪兽和对方怪兽进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力·守备力只在那次伤害计算时变成原本数值的2倍，伤害步骤结束时破坏。
function c67249508.initial_effect(c)
	-- ①：自己的「龙星」怪兽和对方怪兽进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力·守备力只在那次伤害计算时变成原本数值的2倍，伤害步骤结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c67249508.condition)
	e1:SetOperation(c67249508.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：是否为自己的「龙星」怪兽与对方怪兽进行战斗的伤害计算时
function c67249508.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local at=Duel.GetAttackTarget()
	if not at or tc:IsFacedown() or at:IsFacedown() then return false end
	if tc:IsControler(1-tp) then tc=at end
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x9e)
end
-- 效果处理：使该自己怪兽的攻击力·守备力在伤害计算时变成原本数值的2倍，并在伤害步骤结束时将其破坏
function c67249508.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		-- 那只自己怪兽的攻击力只在那次伤害计算时变成原本数值的2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		-- 守备力只在那次伤害计算时变成原本数值的2倍
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense()*2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(67249508,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 伤害步骤结束时破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c67249508.descon)
		e3:SetOperation(c67249508.desop)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册全局效果，在伤害步骤结束时触发破坏效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 破坏效果的触发条件：检查目标怪兽是否仍带有对应的标记，若无则重置该效果
function c67249508.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(67249508)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏效果的执行：将目标怪兽破坏
function c67249508.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽因效果破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
