--マジェスペクター・ソニック
-- 效果：
-- ①：以自己场上1只「威风妖怪」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力变成2倍，给与对方的战斗伤害变成一半。
function c13611090.initial_effect(c)
	-- ①：以自己场上1只「威风妖怪」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力变成2倍，给与对方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果可在伤害步骤且伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c13611090.target)
	e1:SetOperation(c13611090.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是表侧表示且属于「威风妖怪」系列的怪兽。
function c13611090.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd0)
end
-- 发动时的目标选择函数：检查是否存在合法对象并选择1只符合条件的表侧表示「威风妖怪」怪兽作为效果对象。
function c13611090.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13611090.filter(chkc) end
	-- 在发动合法性检查阶段确认场上是否存在至少1只符合条件的对象。
	if chk==0 then return Duel.IsExistingTarget(c13611090.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上的表侧表示「威风妖怪」怪兽中选择1只作为效果对象。
	Duel.SelectTarget(tp,c13611090.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：对选择的怪兽赋予攻击力·守备力翻倍以及给与对方战斗伤害减半的效果。
function c13611090.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时攻击力·守备力变成2倍（此为攻击力部分）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		-- 那只怪兽直到回合结束时攻击力·守备力变成2倍（此为守备力部分）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetDefense()*2)
		tc:RegisterEffect(e2)
		-- 给与对方的战斗伤害变成一半。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		-- 设置该怪兽给予对方战斗伤害变为一半的伤害变更效果。
		e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		tc:RegisterEffect(e3)
	end
end
