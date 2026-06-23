--レインボー・ライフ
-- 效果：
-- 丢弃1张手卡才能发动。直到这个回合的结束阶段时，自己作为因战斗以及卡的效果受到伤害的代替而回复那个数值的基本分。
function c34002992.initial_effect(c)
	-- 丢弃1张手卡才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c34002992.cost)
	e1:SetOperation(c34002992.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足丢弃条件并执行丢弃操作。
function c34002992.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家手牌中是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从玩家手牌中丢弃1张可丢弃的卡片作为代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时，直到这个回合的结束阶段时，自己作为因战斗以及卡的效果受到伤害的代替而回复那个数值的基本分。
function c34002992.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将一个场地区域效果注册给玩家，使其在受到伤害时回复基本分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp，使其生效。
	Duel.RegisterEffect(e1,tp)
end
