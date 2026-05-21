--強引な安全協定
-- 效果：
-- 丢弃1张手卡。这个回合的结束阶段前，不能发动陷阱卡。
function c97806240.initial_effect(c)
	-- 丢弃1张手卡。这个回合的结束阶段前，不能发动陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c97806240.cost)
	e1:SetOperation(c97806240.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：丢弃1张手卡
function c97806240.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查手卡中是否存在至少1张可以丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果处理：在全局注册一个直到回合结束前限制双方发动陷阱卡的效果
function c97806240.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段前，不能发动陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c97806240.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制发动效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判定被发动的效果是否为陷阱卡的发动
function c97806240.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
