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
-- 发动条件判定函数：检查当前是否为战斗阶段，仅在战斗阶段满足时才可发动。
function c29185231.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为战斗阶段。
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
-- 效果处理函数：获取当前回合玩家，跳过其战斗阶段并跳过主要阶段2，使流程直接进入结束阶段。
function c29185231.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家。
	local turnp=Duel.GetTurnPlayer()
	-- 跳过回合玩家的战斗阶段（value=1表示跳过战斗阶段的结束步骤），使其直接结束战斗阶段并进入结束阶段。
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过回合玩家的主要阶段2，使流程直接进入结束阶段。
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
end
