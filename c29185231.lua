--一撃離脱
-- 效果：
-- ①：自己·对方的战斗阶段结束时才能发动。变成这个回合的结束阶段。
function c29185231.initial_effect(c)
	-- ①：自己·对方的战斗阶段结束时才能发动。变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_END)
	e1:SetCondition(c29185231.condition)
	e1:SetOperation(c29185231.activate)
	c:RegisterEffect(e1)
end
-- 检查当前阶段是否为战斗阶段
function c29185231.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为战斗阶段时效果才能发动
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
-- 将目标玩家的战斗阶段和主要阶段2跳过
function c29185231.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过目标玩家的战斗阶段结束步骤，使其进入结束阶段
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过目标玩家的主要阶段2
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
end
