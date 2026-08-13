--ヒロイック・アドバンス
-- 效果：
-- 自己场上的名字带有「英豪」的怪兽被选择作为攻击对象时，选择自己场上1只其他的4星以下的名字带有「英豪」的怪兽才能发动。选择的怪兽的攻击力直到战斗阶段结束时变成2倍，把攻击对象转移为选择的怪兽进行伤害计算。双方怪兽不会被这次战斗破坏。
function c21924381.initial_effect(c)
	-- 自己场上的名字带有「英豪」的怪兽被选择作为攻击对象时，选择自己场上1只其他的4星以下的名字带有「英豪」的怪兽才能发动。选择的怪兽的攻击力直到战斗阶段结束时变成2倍，把攻击对象转移为选择的怪兽进行伤害计算。双方怪兽不会被这次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c21924381.condition)
	e1:SetTarget(c21924381.target)
	e1:SetOperation(c21924381.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：被选择作为攻击对象的怪兽需为表侧表示且由自己控制，并且名字带有「英豪」。
function c21924381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择作为攻击对象的怪兽并存入局部变量d。
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsControler(tp) and d:IsSetCard(0x6f)
end
-- 定义可选对象怪兽的筛选条件：表侧表示、等级4以下、名字带有「英豪」。
function c21924381.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x6f)
end
-- 发动时的目标处理：确认场上存在符合条件的对象，选择1只自己场上其他满足条件的「英豪」怪兽作为效果对象，并让攻击怪兽与效果建立关系。
function c21924381.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21924381.filter(chkc) end
	-- 效果发动合法性检查：确认自己场上存在至少1只不是当前攻击目标且满足条件的「英豪」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c21924381.filter,tp,LOCATION_MZONE,0,1,Duel.GetAttackTarget()) end
	-- 向玩家显示选择对象的提示信息，内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示、4星以下、名字带有「英豪」且不是当前攻击目标的其他怪兽作为效果对象。
	Duel.SelectTarget(tp,c21924381.filter,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	-- 令当前攻击怪兽与本效果建立关联，以便后续处理时确认其仍与效果相关。
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 效果处理：若攻击者和目标怪兽均合法，则将目标怪兽攻击力变为2倍，并赋予双方怪兽不会被战斗破坏的效果，然后强制进行伤害计算。
function c21924381.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽并存入变量a。
	local a=Duel.GetAttacker()
	-- 获取本效果发动时选择的对象怪兽并存入变量tc。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and a:IsAttackable() and a:IsRelateToEffect(e) and not a:IsImmuneToEffect(e)then
		-- 选择的怪兽的攻击力直到战斗阶段结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		-- 双方怪兽不会被这次战斗破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		a:RegisterEffect(e3)
		-- 令攻击怪兽a与对象怪兽tc进行伤害计算，实现将攻击对象转移为选择的怪兽并进行伤害计算。
		Duel.CalculateDamage(a,tc)
	end
end
