--トーテムバード
-- 效果：
-- 风属性3星怪兽×2
-- ①：魔法·陷阱卡发动时，把这张卡2个超量素材取除才能发动。那个发动无效并破坏。
-- ②：没有超量素材的这张卡的攻击力下降300。
function c71068247.initial_effect(c)
	-- 设置XYZ召唤手续：需要2只风属性3星怪兽。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),3,2)
	c:EnableReviveLimit()
	-- ①：魔法·陷阱卡发动时，把这张卡2个超量素材取除才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71068247,0))  --"效果无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c71068247.condition)
	e1:SetCost(c71068247.cost)
	e1:SetTarget(c71068247.target)
	e1:SetOperation(c71068247.operation)
	c:RegisterEffect(e1)
	-- ②：没有超量素材的这张卡的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c71068247.adcon)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
end
-- 检查效果①的发动条件：自身未确定被战斗破坏，且连锁中的卡是魔法·陷阱卡的发动，且该发动可以被无效。
function c71068247.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查当前连锁是否为魔法·陷阱卡的发动，且该发动是否可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 检查并执行发动代价：取除这张卡的2个超量素材。
function c71068247.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 设置效果①的操作信息：将使发动无效和破坏该卡放入操作信息中。
function c71068247.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将使该连锁的发动无效放入操作信息中。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可被破坏且仍存在于关联效果中，则将破坏该卡放入操作信息中。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果①的处理：使发动无效并破坏该卡。
function c71068247.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡与效果有关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 检查效果②的适用条件：这张卡没有超量素材。
function c71068247.adcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
