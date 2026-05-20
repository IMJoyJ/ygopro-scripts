--絶対不可侵領域
-- 效果：
-- 在自己的准备阶段才能发动。丢弃1张手卡。在下一个对方的回合中，对方不能进行通常召唤和特殊召唤。
function c76848240.initial_effect(c)
	-- 在自己的准备阶段才能发动。丢弃1张手卡。在下一个对方的回合中，对方不能进行通常召唤和特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(c76848240.condition)
	e1:SetCost(c76848240.cost)
	e1:SetOperation(c76848240.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制在自己的准备阶段才能发动
function c76848240.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为准备阶段，且当前回合玩家为自己
	return Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp
end
-- 定义发动代价函数，需要丢弃1张手卡
function c76848240.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡中丢弃1张卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果处理函数，注册限制对方召唤、覆盖和特殊召唤的全局效果
function c76848240.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在下一个对方的回合中，对方不能进行通常召唤和特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetCondition(c76848240.efcon)
	-- 将当前回合数记录在效果的Label中，用于后续判断是否为下一个回合
	e1:SetLabel(Duel.GetTurnCount())
	-- 注册限制对方通常召唤的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册限制对方怪兽盖放的全局效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册限制对方特殊召唤的全局效果
	Duel.RegisterEffect(e3,tp)
end
-- 定义限制效果的允许条件函数，用于过滤掉发动当个回合
function c76848240.efcon(e)
	-- 判断当前回合数是否不等于发动时的回合数，以实现“下一个回合”的限制
	return Duel.GetTurnCount()~=e:GetLabel()
end
