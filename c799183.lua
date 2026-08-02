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
c799183.mentioned_counter={
	[0x1]=true,
}
-- 触发条件：自己场上有「混沌战士」怪兽存在，场上的怪兽为对象的怪兽的效果·魔法·陷阱卡发动时
function c799183.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否至少存在1只「混沌战士」怪兽
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x10cf) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果所取对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
		-- 判断当前连锁是否能被无效，并且发动的卡是怪兽卡或者是发动了魔法·陷阱卡
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果对象和操作信息设置：设置无效发动并破坏的发动操作信息
function c799183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含无效发动的效果，预计无效当前连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可破坏，包含破坏效果，预计破坏当前连锁的发动卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使那个发动无效并破坏
function c799183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，并且那张卡还在发动时的位置存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将那张卡效果破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 发动代价：把自己场上1个魔力指示物取除
function c799183.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能作为代价移除1个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 作为代价移除自己场上1个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 效果对象和操作信息设置：判断墓地的这张卡能否盖放
function c799183.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：包含涉及墓地的效果，预计处理这张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡在自己场上盖放，并赋予其离场除外的效果
function c799183.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡还在墓地，且成功将其在自己场上盖放
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
