--ネコマネキング
-- 效果：
-- 对方回合中，当这张卡被对方的魔法、陷阱或效果怪兽的效果送去墓地时，对方的回合立刻结束。
function c11021521.initial_effect(c)
	-- 对方回合中，当这张卡被对方的魔法、陷阱或效果怪兽的效果送去墓地时，对方的回合立刻结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11021521,0))  --"回合结束"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c11021521.condition)
	e1:SetOperation(c11021521.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：当前回合玩家不是这张卡的控制者（即对方回合），且这张卡在送去墓地前由本卡原持有者控制，并且是被对方的魔法、陷阱或效果怪兽的效果送去墓地。
function c11021521.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前是对方回合，且这张卡被送去墓地前的控制者是自己（即这张卡原本由我方控制）。
	return Duel.GetTurnPlayer()~=tp and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 执行“对方的回合立刻结束”的处理：依次跳过对方回合剩余的抽卡阶段、准备阶段、主要阶段1、战斗阶段、主要阶段2，并额外注册一个禁止对方进入战斗阶段的效果。
function c11021521.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方回合的抽卡阶段。
	Duel.SkipPhase(1-tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的准备阶段。
	Duel.SkipPhase(1-tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的主要阶段1。
	Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过对方回合的战斗阶段（value=1表示连战斗阶段的结束步骤也跳过）。
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过对方回合的主要阶段2。
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 对方的回合立刻结束。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的效果注册给对方玩家，确保对方本回合无法再进入战斗阶段，从而完成回合结束的处理。
	Duel.RegisterEffect(e1,tp)
end
