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
-- 检查触发条件
function c11021521.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认当前回合不是控制者且从控制者场上离开，且因效果送入墓地且是对方造成的
	return Duel.GetTurnPlayer()~=tp and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 效果处理函数
function c11021521.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方抽卡阶段
	Duel.SkipPhase(1-tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过对方准备阶段
	Duel.SkipPhase(1-tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过对方主要阶段1
	Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过对方战斗阶段并结束
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过对方主要阶段2
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 以对方玩家为对象，使对方不能进入战斗阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
