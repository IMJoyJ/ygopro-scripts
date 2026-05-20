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
-- 检查发动条件：自己场上有「混沌战士」怪兽存在，且当前连锁的效果是选择场上的怪兽为对象、可以被无效的怪兽效果或魔法·陷阱卡的发动
function c799183.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「混沌战士」怪兽，若不存在则不能发动
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x10cf) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果所选择的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
		-- 且该发动可以被无效，并且该效果是怪兽的效果或者是魔法·陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 检查发动的目标，并设置“使发动无效”和“破坏”的操作信息
function c799183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的对象在场且可以被破坏，则设置操作信息，表示该效果包含“破坏”的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使该发动无效并破坏
function c799183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 成功使发动无效，且该卡在连锁处理时仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 检查并执行发动代价：去除自己场上的1个魔力指示物
function c799183.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能去除1个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 去除自己场上的1个魔力指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 检查目标，并设置“从墓地离开”的操作信息
function c799183.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示该效果包含“卡片离开墓地”的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡在自己场上盖放，并添加离场时除外的效果
function c799183.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其在自己场上盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
