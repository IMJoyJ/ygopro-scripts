--超戦士の盾
-- 效果：
-- ①：自己场上有「混沌战士」怪兽存在，场上的怪兽为对象的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的场合，把自己场上1个魔力指示物取除才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c799183.initial_effect(c)
	-- ①：自己场上有「混沌战士」怪兽存在，场上的怪兽为对象的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c799183.condition)
	e1:SetTarget(c799183.target)
	e1:SetOperation(c799183.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己场上1个魔力指示物取除才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(c799183.setcost)
	e2:SetTarget(c799183.settg)
	e2:SetOperation(c799183.setop)
	c:RegisterEffect(e2)
end
-- 发动条件：自己场上存在「混沌战士」怪兽，且有以场上的怪兽为对象的怪兽的效果或魔法·陷阱卡发动时，且该发动可以被无效
function c799183.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「混沌战士」怪兽
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x10cf) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
		-- 检查该连锁的发动是否可以被无效，且发动的卡片为怪兽的效果或魔法·陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果目标：设置无效该连锁发动以及破坏该卡的操作信息
function c799183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该连锁的发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果该连锁的卡片可以被破坏且仍在场，设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该连锁的发动无效并破坏那张卡
function c799183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动并确认该卡依然存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏触发该连锁发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 发动代价：从自己场上移去1个魔力指示物
function c799183.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能移去1个魔力指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 从自己场上移去1个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 效果目标：检查此卡是否可以盖放，并设置此卡离开墓地的操作信息
function c799183.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置此卡离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡盖放在自己场上，并设置其离场时除外的效果
function c799183.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍与效果相关，则将其盖放在自己场上
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
