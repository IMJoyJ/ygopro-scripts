--閃光弾
-- 效果：
-- 对方场上的怪兽直接攻击成功时才能发动。变成这个回合的结束阶段。
function c9267769.initial_effect(c)
	-- 对方场上的怪兽直接攻击成功时才能发动。变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c9267769.condition)
	e1:SetOperation(c9267769.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：判定是否为对方怪兽直接攻击成功造成的战斗伤害
function c9267769.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定造成伤害的怪兽由对方控制，且攻击对象为空（即直接攻击）
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义效果处理：跳过当前的战斗阶段和主要阶段2，使回合直接进入结束阶段
function c9267769.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方当前的战斗阶段，并跳过战斗阶段的结束步骤
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过对方的主要阶段2，使其在回合结束前无法进行主要阶段2的操作
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
end
