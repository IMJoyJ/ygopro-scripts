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
-- 效果作用
function c35316708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已跳过对方抽卡阶段
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_DP) end
end
-- 效果作用
function c35316708.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方抽卡阶段跳过
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断是否为对方回合且处于抽卡阶段
	if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_DRAW then
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	end
	-- 将跳过抽卡阶段效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
