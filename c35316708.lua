--刻の封印
-- 效果：
-- ①：下次的对方抽卡阶段跳过。
function c35316708.initial_effect(c)
	-- ①：下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c35316708.target)
	e1:SetOperation(c35316708.activate)
	c:RegisterEffect(e1)
end
-- 发动时的条件检测函数：确认对方玩家当前没有被“跳过抽卡阶段”的效果影响，以保证该效果可以合法发动并生效。
function c35316708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查对方玩家是否未受EFFECT_SKIP_DP影响；若对方已处于跳过抽卡阶段的状态，则不能发动本卡。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_DP) end
end
-- 效果处理时，创建一个对对方玩家适用的场地持续效果，令对方跳过下一次抽卡阶段，并根据发动时是否正处于对方抽卡阶段来决定效果的持续时间，最后将该效果注册到场上。
function c35316708.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断当前是否正处于对方回合的抽卡阶段；若是，则说明效果在对方抽卡阶段内发动，需要让“跳过抽卡阶段”的效果持续更久以覆盖下一次对方抽卡阶段。
	if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_DRAW then
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	end
	-- 将生成的“跳过对方抽卡阶段”的持续效果以当前玩家tp的名义注册到场上，使该效果正式适用。
	Duel.RegisterEffect(e1,tp)
end
