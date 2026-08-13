--ブルブレーダー
-- 效果：
-- 这张卡和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对双方玩家的战斗伤害变成0，伤害计算后那只对方怪兽破坏。
function c36088082.initial_effect(c)
	-- 这张卡和对方怪兽进行战斗的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36088082,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c36088082.regcon)
	e1:SetOperation(c36088082.regop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：仅在“本卡”作为攻击怪兽且攻击对象存在，或“本卡”作为被攻击对象时，才允许发动。
function c36088082.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本卡是否参与了与对方怪兽的战斗：若本卡是攻击宣言的怪兽且攻击目标存在，或本卡是攻击目标，则条件满足。
	return (e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil) or e:GetHandler()==Duel.GetAttackTarget()
end
-- 发动时的处理：先给本卡附加本次战斗不给予对方战斗伤害、自己不受到战斗伤害的效果，再在伤害计算后破坏那只对方怪兽。
function c36088082.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 那次战斗发生的对双方玩家的战斗伤害变成0（使对方受到的那次战斗伤害变成0）。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetValue(1)
		c:RegisterEffect(e2)
		-- 伤害计算后那只对方怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLED)
		e3:SetOperation(c36088082.desop)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 把伤害计算后触发破坏效果的事件效果e3注册到tp方，使其在本次战斗的伤害计算后（EVENT_BATTLED）生效。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 伤害计算后的处理：取出与效果持有者进行战斗的怪兽，若仍存在则将其破坏。
function c36088082.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetOwner():GetBattleTarget()
	if tg then
		-- 以效果原因（REASON_EFFECT）破坏那只对方怪兽。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
