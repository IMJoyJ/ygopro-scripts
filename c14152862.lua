--風紀宮司ノリト
-- 效果：
-- 魔法师族6星怪兽×2
-- 1回合1次，对方把魔法·陷阱卡发动时把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c14152862.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足魔法师族条件的怪兽作为素材进行召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),6,2)
	c:EnableReviveLimit()
	-- 1回合1次，对方把魔法·陷阱卡发动时把这张卡1个超量素材取除才能发动。
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
-- 效果发动时的条件判断函数
function c14152862.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断是否为对方发动的魔法或陷阱卡且该连锁可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果发动时的费用支付函数
function c14152862.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的目标设定函数
function c14152862.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的效果信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的操作执行函数
function c14152862.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并判断是否可以破坏对应卡片
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对应连锁的魔法或陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
