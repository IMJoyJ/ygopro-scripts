--フレムベルカウンター
-- 效果：
-- ①：魔法·陷阱卡发动时，从自己墓地把1只守备力200的炎属性怪兽除外才能发动。那个发动无效并破坏。
function c60718396.initial_effect(c)
	-- ①：魔法·陷阱卡发动时，从自己墓地把1只守备力200的炎属性怪兽除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c60718396.condition)
	e1:SetCost(c60718396.cost)
	e1:SetTarget(c60718396.target)
	e1:SetOperation(c60718396.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：魔法·陷阱卡发动时
function c60718396.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为魔法·陷阱卡的发动，且该发动能否被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：自己墓地守备力200的炎属性怪兽，且能作为代价除外
function c60718396.cfilter(c)
	return c:IsDefense(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地把1只守备力200的炎属性怪兽除外
function c60718396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60718396.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c60718396.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理的目标信息（无效与破坏）
function c60718396.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c60718396.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡在连锁中存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
