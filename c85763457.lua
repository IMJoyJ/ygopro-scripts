--星遺物に響く残叫
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有互相连接状态的怪兽存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c85763457.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有互相连接状态的怪兽存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,85763457+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c85763457.condition)
	e1:SetTarget(c85763457.target)
	e1:SetOperation(c85763457.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且处于互相连接状态的怪兽
function c85763457.cfilter(c)
	return c:IsFaceup() and c:GetMutualLinkedGroupCount()>0
end
-- 发动条件：对方发动怪兽效果或魔陷卡，且自己场上有互相连接状态的怪兽存在，该发动可以被无效
function c85763457.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动效果，且自己场上是否存在至少1只表侧表示的互相连接状态的怪兽
	if ep==tp or not Duel.IsExistingMatchingCard(c85763457.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查该连锁的发动是否可以被无效，且该效果是否为怪兽效果或魔法·陷阱卡的发动
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果的目标处理：设置无效发动与破坏的操作信息
function c85763457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将发动的卡破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：使发动的效果无效并破坏该卡
function c85763457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，并检查发动的卡是否仍与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
