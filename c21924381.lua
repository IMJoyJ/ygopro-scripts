--ヒロイック・アドバンス
-- 效果：
-- 自己场上的名字带有「英豪」的怪兽被选择作为攻击对象时，选择自己场上1只其他的4星以下的名字带有「英豪」的怪兽才能发动。选择的怪兽的攻击力直到战斗阶段结束时变成2倍，把攻击对象转移为选择的怪兽进行伤害计算。双方怪兽不会被这次战斗破坏。
function c21924381.initial_effect(c)
	-- 效果定义：当自己场上的名字带有「英豪」的怪兽被选择作为攻击对象时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c21924381.condition)
	e1:SetTarget(c21924381.target)
	e1:SetOperation(c21924381.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：攻击对象是自己场上的表侧表示的「英豪」怪兽
function c21924381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击对象
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsControler(tp) and d:IsSetCard(0x6f)
end
-- 过滤器：选择自己场上4星以下的「英豪」怪兽
function c21924381.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x6f)
end
-- 效果目标选择：选择1只自己场上的4星以下的「英豪」怪兽作为效果对象
function c21924381.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21924381.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c21924381.filter,tp,LOCATION_MZONE,0,1,Duel.GetAttackTarget()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c21924381.filter,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	-- 将攻击怪兽与效果关联
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 效果发动：将选择的怪兽攻击力变为2倍并转移攻击对象
function c21924381.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and a:IsAttackable() and a:IsRelateToEffect(e) and not a:IsImmuneToEffect(e)then
		-- 将选择的怪兽攻击力变为2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		-- 使选择的怪兽和攻击怪兽在本次战斗中不会被破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		a:RegisterEffect(e3)
		-- 进行伤害计算
		Duel.CalculateDamage(a,tc)
	end
end
