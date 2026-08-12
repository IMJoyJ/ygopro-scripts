--覇者の一括
-- 效果：
-- 在对方的准备阶段发动。对方本回合不能进行战斗阶段。
function c91781589.initial_effect(c)
	-- 在对方的准备阶段发动。对方本回合不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCondition(c91781589.condition)
	e1:SetOperation(c91781589.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的条件函数
function c91781589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合的准备阶段
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 定义卡片发动后的效果处理函数
function c91781589.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方本回合不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	-- 将限制对方玩家不能进行战斗阶段的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
