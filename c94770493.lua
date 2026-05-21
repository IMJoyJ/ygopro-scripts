--ダブル・アップ・チャンス
-- 效果：
-- ①：怪兽的攻击无效时，以那1只怪兽为对象才能发动。这次战斗阶段中，那只怪兽再1次可以攻击。这个效果让那只怪兽攻击的伤害步骤内，那只怪兽的攻击力变成2倍。
function c94770493.initial_effect(c)
	-- ①：怪兽的攻击无效时，以那1只怪兽为对象才能发动。这次战斗阶段中，那只怪兽再1次可以攻击。这个效果让那只怪兽攻击的伤害步骤内，那只怪兽的攻击力变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c94770493.target)
	e1:SetOperation(c94770493.operation)
	c:RegisterEffect(e1)
end
-- 确认攻击被无效的怪兽是否可以成为效果对象，并进行对象选择
function c94770493.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==eg:GetFirst() end
	if chk==0 then return eg:GetFirst():IsFaceup() and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 将攻击被无效的那1只怪兽设为效果的对象
	Duel.SetTargetCard(eg:GetFirst())
end
-- 使作为对象的怪兽在本次战斗阶段中可以再进行1次攻击，并在该怪兽攻击的伤害步骤内攻击力变成2倍
function c94770493.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetFlagEffect(94770493)==0 then
		tc:RegisterFlagEffect(94770493,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		-- 这次战斗阶段中，那只怪兽再1次可以攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		-- 这个效果让那只怪兽攻击的伤害步骤内，那只怪兽的攻击力变成2倍。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetCondition(c94770493.atkcon)
		e2:SetValue(c94770493.atkval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e2)
	end
end
-- 判断当前是否处于伤害步骤或伤害计算时，且进行攻击的怪兽是该怪兽自身
function c94770493.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 如果当前处于伤害步骤或伤害计算时，且当前进行攻击的怪兽是该怪兽自身
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttacker()==e:GetHandler() then
		e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE+PHASE_BATTLE)
		return true
	end
	return false
end
-- 计算并返回该怪兽当前攻击力2倍的数值
function c94770493.atkval(e,c)
	return e:GetHandler():GetAttack()*2
end
