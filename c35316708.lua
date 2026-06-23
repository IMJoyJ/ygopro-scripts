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
-- 定义target函数，检查对方玩家是否已受跳过抽卡阶段效果影响，以决定是否可发动此卡。
function c35316708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方玩家是否未受“跳过抽卡阶段”效果影响，若未受影响则满足发动条件。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_DP) end
end
-- 定义activate函数，创建并注册一个跳过对方抽卡阶段的效果，使对方在下一次抽卡阶段跳过抽卡。
function c35316708.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断当前是否为对方回合且处于抽卡阶段，若是则调整效果重置次数为2。
	if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_DRAW then
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	end
	-- 将跳过抽卡阶段的效果注册到发动此卡的玩家，使其在对方回合生效。
	Duel.RegisterEffect(e1,tp)
end
