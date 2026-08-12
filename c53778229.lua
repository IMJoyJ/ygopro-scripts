--墓地封印
-- 效果：
-- ①：丢弃1张手卡才能发动。这个回合，墓地发动的卡的效果无效化。
function c53778229.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。这个回合，墓地发动的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c53778229.cost)
	e1:SetOperation(c53778229.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组并丢弃1张手卡作为发动代价
function c53778229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的自己的手牌区是否存在至少1张满足Card.IsDiscardable条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家tp丢弃1张满足Card.IsDiscardable条件的手卡，丢弃原因为REASON_COST+REASON_DISCARD
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 将一个永续效果注册到场上，用于在连锁处理时判断是否无效墓地发动的效果
function c53778229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将一个永续效果注册到场上，用于在连锁处理时判断是否无效墓地发动的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(c53778229.disop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp，使其成为全局生效的效果
	Duel.RegisterEffect(e1,tp)
end
-- 当连锁处理时，判断该连锁是否由墓地发动，若是则使其无效
function c53778229.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
