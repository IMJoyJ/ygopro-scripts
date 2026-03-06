--ソロモンの律法書
-- 效果：
-- 下次的自己的准备阶段跳过。
function c23471572.initial_effect(c)
	-- 效果原文：下次的自己的准备阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c23471572.target)
	e1:SetOperation(c23471572.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否可以发动此卡（未被跳过准备阶段影响）
function c23471572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否可以发动此卡（未被跳过准备阶段影响）
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_SP) end
end
-- 效果作用：设置卡的效果，在自己回合的准备阶段跳过准备阶段
function c23471572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：下次的自己的准备阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_SKIP_SP)
	-- 效果作用：判断是否在自己的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		e1:SetCondition(c23471572.skipcon)
		-- 效果作用：记录当前回合数，用于判断是否为下次准备阶段
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	end
	-- 效果作用：将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：判断是否为下次准备阶段的条件函数
function c23471572.skipcon(e)
	-- 效果作用：判断当前回合数是否与记录的回合数不同，用于触发跳过准备阶段
	return Duel.GetTurnCount()~=e:GetLabel()
end
