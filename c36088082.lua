--ブルブレーダー
-- 效果：
-- 这张卡和对方怪兽进行战斗的攻击宣言时才能发动。那次战斗发生的对双方玩家的战斗伤害变成0，伤害计算后那只对方怪兽破坏。
function c36088082.initial_effect(c)
	-- 效果原文：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36088082,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c36088082.regcon)
	e1:SetOperation(c36088082.regop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：当前卡是攻击怪兽或被攻击怪兽
function c36088082.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前卡是攻击怪兽且存在攻击目标，或当前卡是攻击目标
	return (e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil) or e:GetHandler()==Duel.GetAttackTarget()
end
-- 效果发动时执行的操作：设置不造成战斗伤害和破坏对方怪兽
function c36088082.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 效果原文：那次战斗发生的对双方玩家的战斗伤害变成0
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
		-- 效果原文：伤害计算后那只对方怪兽破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLED)
		e3:SetOperation(c36088082.desop)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将效果e3注册到玩家tp的全局环境，用于在伤害计算后触发
		Duel.RegisterEffect(e3,tp)
	end
end
-- 破坏对方怪兽时执行的操作：获取战斗中的对方怪兽并将其破坏
function c36088082.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetOwner():GetBattleTarget()
	if tg then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
