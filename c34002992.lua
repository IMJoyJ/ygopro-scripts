--レインボー・ライフ
-- 效果：
-- 丢弃1张手卡才能发动。直到这个回合的结束阶段时，自己作为因战斗以及卡的效果受到伤害的代替而回复那个数值的基本分。
function c34002992.initial_effect(c)
	-- 丢弃1张手卡才能发动。直到这个回合的结束阶段时，自己作为因战斗以及卡的效果受到伤害的代替而回复那个数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c34002992.cost)
	e1:SetOperation(c34002992.activate)
	c:RegisterEffect(e1)
end
-- 该函数是发动效果的代价（cost）处理：检查手牌是否满足丢弃条件，并实际执行丢弃1张手卡作为发动代价。
function c34002992.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认自己手牌中是否存在至少1张可以丢弃的卡（排除发动效果的这张卡），以此判断能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从自己手牌中选择1张可丢弃的卡，以COST+DISCARD的原因丢弃，满足发动所需代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理阶段：给自己施加一个持续到结束阶段的伤害反转效果，使之后因战斗或卡的效果受到的伤害变为回复相同数值的基本分。
function c34002992.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到这个回合的结束阶段时，自己作为因战斗以及卡的效果受到伤害的代替而回复那个数值的基本分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个‘伤害变回复’的持续效果注册到当前玩家（tp）身上，使该效果从此刻开始适用。
	Duel.RegisterEffect(e1,tp)
end
