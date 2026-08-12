--ラスト・カウンター
-- 效果：
-- 自己场上的名字带有「燃烧拳击手」的怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那次攻击无效，那只自己怪兽送去墓地。自己场上1只名字带有「燃烧拳击手」的怪兽的攻击力上升那只对方怪兽的原本攻击力数值，和那只对方怪兽进行伤害计算。那之后，自己受到这张卡的效果上升的攻击力数值的伤害。
function c86049351.initial_effect(c)
	-- 自己场上的名字带有「燃烧拳击手」的怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那次攻击无效，那只自己怪兽送去墓地。自己场上1只名字带有「燃烧拳击手」的怪兽的攻击力上升那只对方怪兽的原本攻击力数值，和那只对方怪兽进行伤害计算。那之后，自己受到这张卡的效果上升的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c86049351.condition)
	e1:SetTarget(c86049351.target)
	e1:SetOperation(c86049351.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上的「燃烧拳击手」怪兽与对方怪兽进行战斗的攻击宣言时，并将该自己怪兽保存到LabelObject中
function c86049351.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽（攻击目标）
	local at=Duel.GetAttackTarget()
	if not at or tc:IsFacedown() or at:IsFacedown() then return false end
	if not tc:IsControler(tp) then tc=at end
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x1084)
end
-- 过滤条件：自己场上指定表示形式的「燃烧拳击手」怪兽
function c86049351.filter(c,pos)
	return c:IsPosition(pos) and c:IsSetCard(0x1084)
end
-- 检查效果发动的可行性：自己场上是否存在除进行战斗的那只怪兽以外、满足特定表示形式的「燃烧拳击手」怪兽
function c86049351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=e:GetLabelObject()
		local bc=tc:GetBattleTarget()
		local pos=POS_FACEUP
		-- 如果对方怪兽是被攻击方，则后续选择的自己怪兽必须是表侧攻击表示
		if bc==Duel.GetAttackTarget() then pos=POS_FACEUP_ATTACK end
		-- 检查自己场上是否存在除进行战斗的那只怪兽以外、满足表示形式要求的「燃烧拳击手」怪兽
		return Duel.IsExistingMatchingCard(c86049351.filter,tp,LOCATION_MZONE,0,1,tc,pos)
	end
end
-- 效果处理：无效攻击并送墓自己怪兽，选择另1只「燃烧拳击手」怪兽上升攻击力并与对方怪兽进行伤害计算，最后自己受到伤害
function c86049351.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	-- 无效此次攻击，并确认进行战斗的两只怪兽仍存在于场上且对方怪兽表侧表示
	if Duel.NegateAttack() and tc:IsRelateToBattle() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 将进行战斗的那只自己怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
		local pos=POS_FACEUP
		-- 如果对方怪兽是被攻击方，则后续选择的自己怪兽必须是表侧攻击表示
		if bc==Duel.GetAttackTarget() then pos=POS_FACEUP_ATTACK end
		-- 提示玩家选择要上升攻击力并进行战斗的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择自己场上1只满足表示形式要求的「燃烧拳击手」怪兽
		local g=Duel.SelectMatchingCard(tp,c86049351.filter,tp,LOCATION_MZONE,0,1,1,nil,pos)
		local sc=g:GetFirst()
		local atk=bc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 自己场上1只名字带有「燃烧拳击手」的怪兽的攻击力上升那只对方怪兽的原本攻击力数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		-- 调整伤害计算的攻守双方顺序，确保攻击方和被攻击方的关系正确
		if bc==Duel.GetAttackTarget() then bc,sc=sc,bc end
		if bc:IsAttackable() and not bc:IsImmuneToEffect(e) and not sc:IsImmuneToEffect(e) then
			-- 令选中的「燃烧拳击手」怪兽与对方怪兽进行伤害计算
			Duel.CalculateDamage(bc,sc)
			-- 中断当前效果处理，使之后的伤害处理视为不同时处理
			Duel.BreakEffect()
			-- 给与自己等同于上升攻击力数值的伤害
			Duel.Damage(tp,atk,REASON_EFFECT)
		end
	end
end
