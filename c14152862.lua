--風紀宮司ノリト
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，对方把魔法·陷阱卡发动时把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c14152862.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只魔法师族6星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),6,2)
	c:EnableReviveLimit()
	-- “1回合1次，对方把魔法·陷阱卡发动时把这张卡1个超量素材取除才能发动。那个发动无效并破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14152862,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c14152862.discon)
	e1:SetCost(c14152862.discost)
	e1:SetTarget(c14152862.distg)
	e1:SetOperation(c14152862.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：我方场上此卡未被战斗破坏确定，且对方发动了魔法·陷阱卡的发动，且该连锁可以被无效。
function c14152862.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判定发动时机：对方发动魔法·陷阱卡（卡的发动）且该连锁可被无效，满足时效果可发动。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 发动代价处理：检查并取除这张卡的1个超量素材作为发动代价。
function c14152862.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时的目标处理：将对方发动的魔法·陷阱卡设为无效对象，若其可被破坏且仍与效果关联，则同时设为破坏对象。
function c14152862.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将无效对方的魔法·陷阱卡的发动，对象为连锁中的对方卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次效果将破坏对方的魔法·陷阱卡，对象为连锁中的对方卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对方魔法·陷阱卡的发动；若无效成功且该卡仍与效果关联，则将其破坏。
function c14152862.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁，并确认对应的魔法·陷阱卡仍与效果关联，确保其未因其他处理离开。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该魔法·陷阱卡以效果破坏并送去墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
