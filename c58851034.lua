--封魔の呪印
-- 效果：
-- 从自己手卡中丢弃1张魔法卡。使魔法卡的发动及效果无效，并且将其破坏。对方在本次决斗中不能再发动因这张卡效果而被破坏的魔法卡及其同名卡。
function c58851034.initial_effect(c)
	-- 从自己手卡中丢弃1张魔法卡。使魔法卡的发动及效果无效，并且将其破坏。对方在本次决斗中不能再发动因这张卡效果而被破坏的魔法卡及其同名卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c58851034.condition)
	e1:SetCost(c58851034.cost)
	e1:SetTarget(c58851034.target)
	e1:SetOperation(c58851034.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查被连锁的效果是否为魔法卡的发动，且该发动可以被无效
function c58851034.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否为魔法卡的发动，且该发动可以被无效
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤手卡中可以丢弃的魔法卡
function c58851034.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 发动代价：从手卡丢弃1张魔法卡（若受免除代价效果影响则免除）
function c58851034.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若玩家受到免除反制陷阱丢弃手卡代价的效果影响，则无需支付代价
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 在发动时检查手卡中是否存在至少1张可以丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58851034.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张魔法卡丢弃
	Duel.DiscardHand(tp,c58851034.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果的目标：设置无效发动和破坏卡片的操作信息
function c58851034.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被连锁的卡可以被破坏且仍存在于连锁中，设置操作信息，表示该效果包含“破坏”的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：使魔法卡的发动无效并破坏，之后注册限制对方发动同名卡的全局效果
function c58851034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该魔法卡的发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 若成功将该卡破坏
		if Duel.Destroy(eg,REASON_EFFECT)>0 then
			-- 对方在本次决斗中不能再发动因这张卡效果而被破坏的魔法卡及其同名卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(0,1)
			e1:SetValue(c58851034.aclimit)
			e1:SetLabel(re:GetHandler():GetCode())
			-- 将限制发动的效果注册给玩家，持续至决斗结束
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制发动的过滤条件：禁止对方发动与被破坏魔法卡同名的魔法卡
function c58851034.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
