--エヴォルカイザー・ラギア
-- 效果：
-- 恐龙族4星怪兽×2
-- ①：可以把这张卡2个超量素材取除，以下效果发动。
-- ●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c74294676.initial_effect(c)
	-- 为这张卡添加超量召唤手续：恐龙族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),4,2)
	c:EnableReviveLimit()
	-- ①：可以把这张卡2个超量素材取除，以下效果发动。●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74294676,0))  --"魔法·陷阱卡的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c74294676.condition1)
	e1:SetCost(c74294676.cost1)
	e1:SetTarget(c74294676.target1)
	e1:SetOperation(c74294676.operation1)
	c:RegisterEffect(e1)
	-- ①：可以把这张卡2个超量素材取除，以下效果发动。●自己或对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74294676,1))  --"召唤无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON)
	e2:SetCondition(c74294676.condition2)
	e2:SetCost(c74294676.cost2)
	e2:SetTarget(c74294676.target2)
	e2:SetOperation(c74294676.operation2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(74294676,2))  --"特殊召唤无效并破坏"
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 魔法·陷阱卡发动无效效果的发动条件：自身未处于战斗破坏确定状态，且有魔法·陷阱卡的发动，且该发动可以被无效
function c74294676.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查当前连锁是魔法·陷阱卡的发动，且该发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 魔法·陷阱卡发动无效效果的代价：取除这张卡的2个超量素材
function c74294676.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 魔法·陷阱卡发动无效效果的发动准备：设置无效发动和破坏的操作信息
function c74294676.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可破坏且仍存在于场上，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法·陷阱卡发动无效效果的处理：使发动无效并破坏该卡
function c74294676.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡与效果有关联（仍在原位置）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 召唤·特殊召唤无效效果的发动条件：当前没有正在处理的连锁（即在召唤/特殊召唤之际）
function c74294676.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁数是否为0（确保是召唤/特殊召唤之际，而不是在连锁处理中）
	return Duel.GetCurrentChain()==0
end
-- 召唤·特殊召唤无效效果的代价：取除这张卡的2个超量素材
function c74294676.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 召唤·特殊召唤无效效果的发动准备：设置无效召唤和破坏怪兽的操作信息
function c74294676.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使这些怪兽的召唤·特殊召唤无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏这些召唤·特殊召唤被无效的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤·特殊召唤无效效果的处理：使召唤·特殊召唤无效，并破坏那些怪兽
function c74294676.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤·特殊召唤的怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 因效果破坏那些怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
