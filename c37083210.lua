--クロスカウンター
-- 效果：
-- 受攻击的守备表示怪兽的守备力，比对方攻击怪兽的攻击力高的场合，给与对方的战斗伤害变成2倍。伤害计算后那只攻击怪兽破坏。
function c37083210.initial_effect(c)
	-- 效果发动条件设置，用于在伤害步骤时点发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c37083210.condition)
	e1:SetOperation(c37083210.activate)
	c:RegisterEffect(e1)
end
-- 判断是否处于伤害步骤且未计算伤害
function c37083210.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的攻击目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断当前阶段为伤害步骤且尚未计算伤害
	return Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated()
		and a:IsControler(1-tp) and at and at:IsPosition(POS_FACEUP_DEFENSE) and a:GetAttack()<at:GetDefense()
end
-- 效果发动时执行的操作，设置战斗伤害翻倍并破坏攻击怪兽
function c37083210.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击目标怪兽
	local at=Duel.GetAttackTarget()
	if at:IsFaceup() and at:IsRelateToBattle() then
		-- 创建一个改变战斗伤害的效果，使对方受到的战斗伤害翻倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(c37083210.dcon)
		-- 设置战斗伤害翻倍效果的值为DOUBLE_DAMAGE（即2倍）
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		at:RegisterEffect(e1)
		-- 创建一个在战斗结束后触发的效果，用于破坏攻击怪兽
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_BATTLED)
		e2:SetOperation(c37083210.desop)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将该效果注册到场上，使其在伤害步骤结束后生效
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断该效果是否作用于当前攻击怪兽
function c37083210.dcon(e)
	local c=e:GetHandler()
	-- 判断当前效果是否作用于攻击怪兽
	return Duel.GetAttackTarget()==c
end
-- 当战斗结束时触发，用于破坏攻击怪兽
function c37083210.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否仍处于战斗状态
	if Duel.GetAttacker():IsRelateToBattle() then
		-- 将攻击怪兽从场上破坏
		Duel.Destroy(Duel.GetAttacker(),REASON_EFFECT)
	end
end
