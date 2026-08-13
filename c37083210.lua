--クロスカウンター
-- 效果：
-- 受攻击的守备表示怪兽的守备力，比对方攻击怪兽的攻击力高的场合，给与对方的战斗伤害变成2倍。伤害计算后那只攻击怪兽破坏。
function c37083210.initial_effect(c)
	-- 受攻击的守备表示怪兽的守备力，比对方攻击怪兽的攻击力高的场合，给与对方的战斗伤害变成2倍。伤害计算后那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c37083210.condition)
	e1:SetOperation(c37083210.activate)
	c:RegisterEffect(e1)
end
-- 判定效果能否发动的条件：当前必须处于伤害步骤且尚未进行伤害计算，攻击怪兽必须是对方怪兽，被攻击怪兽必须为表侧守备表示，且攻击怪兽的攻击力小于被攻击怪兽的守备力。
function c37083210.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗中的被攻击怪兽（攻击目标）。
	local at=Duel.GetAttackTarget()
	-- 确认当前阶段为伤害步骤（PHASE_DAMAGE）且战斗伤害还没有计算（not Duel.IsDamageCalculated()），保证在伤害计算前的正确时点发动。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated()
		and a:IsControler(1-tp) and at and at:IsPosition(POS_FACEUP_DEFENSE) and a:GetAttack()<at:GetDefense()
end
-- 效果处理：先检查被攻击怪兽仍表侧表示且仍与本次战斗关联，然后给该守备怪兽附加战斗伤害变为2倍的效果，并注册一个在伤害计算后破坏攻击怪兽的诱发效果。
function c37083210.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击怪兽（攻击目标）。
	local at=Duel.GetAttackTarget()
	if at:IsFaceup() and at:IsRelateToBattle() then
		-- 给与对方的战斗伤害变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(c37083210.dcon)
		-- 设置伤害变更效果：对方玩家受到的战斗伤害变为原来的2倍（DOUBLE_DAMAGE）。
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		at:RegisterEffect(e1)
		-- 伤害计算后那只攻击怪兽破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_BATTLED)
		e2:SetOperation(c37083210.desop)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将伤害计算后破坏攻击怪兽的持续效果注册到场上（作用对象为双方怪兽的事件监听）。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害变更效果的适用条件判定：当前被攻击怪兽仍然是效果所附着的那只守备怪兽。
function c37083210.dcon(e)
	local c=e:GetHandler()
	-- 检查当前攻击目标是否正是这只守备怪兽，只有此时才会让战斗伤害翻倍效果生效。
	return Duel.GetAttackTarget()==c
end
-- 伤害计算后处理：若攻击怪兽仍与本次战斗关联，则将其破坏。
function c37083210.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否仍存在于场上且与本次战斗保持关联（未离场或除外），防止误破坏已经离开战斗的怪兽。
	if Duel.GetAttacker():IsRelateToBattle() then
		-- 以卡牌效果（REASON_EFFECT）为原因破坏该攻击怪兽。
		Duel.Destroy(Duel.GetAttacker(),REASON_EFFECT)
	end
end
