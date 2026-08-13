--ソロモンの律法書
-- 效果：
-- 下次的自己的准备阶段跳过。
function c23471572.initial_effect(c)
	-- 下次的自己的准备阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c23471572.target)
	e1:SetOperation(c23471572.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：己方没有处于“跳过准备阶段”效果影响下时才可发动。
function c23471572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方是否未被 EFFECT_SKIP_SP 效果影响；若已受影响则本卡不能发动。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_SP) end
end
-- 发动处理：给己方玩家设置一个“跳过准备阶段”的场上永续效果，使其在后续满足条件时跳过准备阶段。
function c23471572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己的准备阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_SKIP_SP)
	-- 判断发动时是否为己方准备阶段：若是，则通过条件限制让效果从下一个准备阶段才开始生效。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		e1:SetCondition(c23471572.skipcon)
		-- 记录当前回合数作为标签，供跳过条件比较，以确保只跳过下一个准备阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	end
	-- 将跳过准备阶段的效果注册给己方玩家，使该效果开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 跳过条件函数：只有当前回合数不等于记录值时（即已到下个回合的准备阶段），跳过效果才适用。
function c23471572.skipcon(e)
	-- 返回当前回合数是否已变化，决定是否跳过本准备阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
