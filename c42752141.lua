--エヴォルカイザー・ドルカ
-- 效果：
-- 恐龙族4星怪兽×2
-- ①：这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c42752141.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足恐龙族条件的怪兽作为素材进行召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42752141,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42752141.condition)
	e1:SetCost(c42752141.cost)
	e1:SetTarget(c42752141.target)
	e1:SetOperation(c42752141.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断，确保不是自身发动且怪兽效果可被无效
function c42752141.condition(e,tp,eg,ep,ev,re,r,rp)
	return re~=e and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确保发动的是怪兽效果且该连锁可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付效果的代价，从自身取除1个超量素材
function c42752141.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏目标怪兽
function c42752141.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时执行的操作，先使连锁无效再破坏目标怪兽
function c42752141.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且目标怪兽仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
