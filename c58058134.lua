--シャイニート・マジシャン
-- 效果：
-- 1星怪兽×2
-- ①：这张卡1回合只有1次不会被战斗破坏。
-- ②：场上的这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c58058134.initial_effect(c)
	-- 添加超量召唤手续：1星怪兽×2
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c58058134.valcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58058134,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c58058134.negcon)
	e2:SetCost(c58058134.negcost)
	e2:SetTarget(c58058134.negtg)
	e2:SetOperation(c58058134.negop)
	c:RegisterEffect(e2)
end
-- 判定破坏原因为战斗破坏
function c58058134.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 检查发动的效果是否以场上的这张卡为对象
function c58058134.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
-- 移除1个超量素材作为发动的代价
function c58058134.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标，设置无效与破坏的操作信息
function c58058134.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息为破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理，使该发动无效并破坏
function c58058134.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
