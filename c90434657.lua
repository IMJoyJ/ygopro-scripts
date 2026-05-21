--ネクロバレーの王墓
-- 效果：
-- 场上有名字带有「守墓」的怪兽以及「王家长眠之谷」存在的场合才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。「王家长眠之谷的王墓」在1回合只能发动1张。
function c90434657.initial_effect(c)
	-- 场上有名字带有「守墓」的怪兽以及「王家长眠之谷」存在的场合才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。「王家长眠之谷的王墓」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,90434657+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c90434657.condition)
	e1:SetTarget(c90434657.target)
	e1:SetOperation(c90434657.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「守墓」怪兽
function c90434657.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
-- 发动条件：检查场上是否存在「守墓」怪兽以及「王家长眠之谷」
function c90434657.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在表侧表示的「守墓」怪兽
	if not Duel.IsExistingMatchingCard(c90434657.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查场上是否存在「王家长眠之谷」，若不存在则返回false
		or not Duel.IsEnvironment(47355498) then return false end
	-- 检查被连锁的效果是否可以被无效，若不能则返回false
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果发动的目标与操作信息设置
function c90434657.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c90434657.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该发动，且该卡与该效果仍有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
