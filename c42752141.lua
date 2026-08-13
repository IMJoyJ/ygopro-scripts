--エヴォルカイザー・ドルカ
-- 效果：
-- 恐龙族4星怪兽×2
-- ①：这张卡以外的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c42752141.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只恐龙族4星怪兽叠放作为超量素材进行XYZ召唤。
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
-- 效果发动条件：不处于战斗破坏确定状态、不是本效果自身、发动中的效果为怪兽效果且该连锁的发动可以被无效时才能发动。
function c42752141.condition(e,tp,eg,ep,ev,re,r,rp)
	return re~=e and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步判定：触发的效果是怪兽效果，且该连锁的发动可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付代价：检查并取除这张卡的1个超量素材作为效果发动的代价。
function c42752141.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理前设置操作信息：将无效对象设为正在发动的效果；若其效果怪兽可被破坏且仍与该效果关联，则同时设置破坏对象。
function c42752141.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：无效类别，对象为触发连锁的卡（eg），数量1，表示要无效该效果的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置本次连锁的操作信息：破坏类别，对象为触发连锁的卡（eg），数量1，表示要破坏那张卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时：先无效对方怪兽效果的发动；若无效成功且该怪兽仍与所发动的效果相关联，则将其破坏。
function c42752141.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果该连锁的发动被成功无效，且效果怪兽仍与所发动效果存在关联（未离场或失去联系），才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏eg中的卡，即发动了被无效效果的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
