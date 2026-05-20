--マジック・ジャマー
-- 效果：
-- ①：魔法卡发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
function c77414722.initial_effect(c)
	-- ①：魔法卡发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c77414722.condition)
	e1:SetCost(c77414722.cost)
	e1:SetTarget(c77414722.target)
	e1:SetOperation(c77414722.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查当前连锁是否为魔法卡的发动，且该发动是否可以被无效
function c77414722.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断触发连锁的效果是否为魔法卡的发动，且该发动可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 发动代价：检查并执行丢弃1张手卡的操作
function c77414722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若玩家受到免除丢弃手卡代价的效果影响（如解放之阿里阿德涅），则无需支付代价
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 在发动检查阶段，确认手卡中是否存在至少1张可以丢弃的卡（排除此卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 在发动执行阶段，从手卡中选择1张卡丢弃作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果目标：设置使发动无效并破坏的操作信息
function c77414722.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若该卡可被破坏且与效果有关联，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：执行无效并破坏的操作
function c77414722.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该魔法卡的发动无效，且该卡在场上与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该魔法卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
