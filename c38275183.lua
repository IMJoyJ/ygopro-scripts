--八式対魔法多重結界
-- 效果：
-- 从下列效果中选择1项发动：
-- ●使1张以场上1只怪兽为对象的魔法卡的发动与效果无效，并且把它破坏。
-- ●从手卡把1张魔法卡送去墓地。使1张魔法卡的发动与效果无效，并且把它破坏。
function c38275183.initial_effect(c)
	-- 从下列效果中选择1项发动：●使1张以场上1只怪兽为对象的魔法卡的发动与效果无效，并且把它破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38275183,0))  --"直接无效取1只怪兽为对象的魔法卡"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c38275183.condition1)
	e1:SetTarget(c38275183.target)
	e1:SetOperation(c38275183.activate)
	c:RegisterEffect(e1)
	-- 从下列效果中选择1项发动：●从手卡把1张魔法卡送去墓地。使1张魔法卡的发动与效果无效，并且把它破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38275183,1))  --"把手卡送去墓地无效魔法卡"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c38275183.condition2)
	e2:SetCost(c38275183.cost)
	e2:SetTarget(c38275183.target)
	e2:SetOperation(c38275183.activate)
	c:RegisterEffect(e2)
end
-- e1的发动条件：被连锁的效果必须是取1只场上怪兽为对象的魔法卡发动（要求带取对象标志、对象仅有1张且在怪兽区），且该发动可被无效。
function c38275183.condition1(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取被连锁效果取对象的卡片组，用于检查对象数量及是否位于怪兽区。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:GetCount()==1 and tg:GetFirst():IsLocation(LOCATION_MZONE)
		-- 追加判定：被连锁效果必须是魔法卡的发动，且该发动可以被无效。
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- e2的发动条件：被连锁的效果是魔法卡的发动且该发动可以被无效，不要求取对象。
function c38275183.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁效果是否为魔法卡的发动且该发动可以被无效。
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 筛选函数：选择手卡中可作为代价送去墓地的魔法卡。
function c38275183.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 代价处理：检查手卡是否存在符合条件的魔法卡，然后选择1张从手卡送去墓地作为发动代价。
function c38275183.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手卡存在至少1张可作为代价的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38275183.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择并送去墓地1张魔法卡，原因为代价。
	Duel.DiscardHand(tp,c38275183.cfilter,1,1,REASON_COST,nil)
end
-- target处理：无选择对象；设置使该魔法卡发动无效的操作信息，若该魔法卡可被破坏且仍与连锁相关，则一并设置破坏信息。
function c38275183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的魔法卡登记为无效对象（使发动无效）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将当前连锁的魔法卡登记为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效被连锁魔法卡的发动与效果；若该卡仍与连锁相关，则将其破坏。
function c38275183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效化，并检查被无效的魔法卡是否仍与连锁相关，以便进行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将当前连锁涉及的魔法卡破坏，破坏原因为效果。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
