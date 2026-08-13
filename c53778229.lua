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
-- 定义发动代价函数：在发动前检查手牌能否丢弃1张，并实际丢弃；若不能丢弃则无法发动。
function c53778229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前的合法性检查（chk==0）：确认自己手牌中存在至少1张可丢弃的卡，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 以代价形式从手牌选择并丢弃1张卡（丢弃原因为发动代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义发动成功后的处理：新建一个持续效果，类型为全场连续效果，触发事件为连锁处理时，操作函数为c53778229.disop，并在回合结束时重置，然后注册到当前玩家场上。
function c53778229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，墓地发动的卡的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(c53778229.disop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该持续效果注册到当前玩家（tp）一方，使其从此刻开始对全场连锁生效，直到阶段结束时重置。
	Duel.RegisterEffect(e1,tp)
end
-- 定义持续效果的触发操作：检索当前连锁的发动位置，如果位于墓地则使该连锁效果无效。
function c53778229.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前正在处理的连锁效果的发动位置（墓地/手牌/场上等）。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then
		-- 将指定连锁的效果无效化（此处即无效化墓地发动的卡的效果）。
		Duel.NegateEffect(ev)
	end
end
