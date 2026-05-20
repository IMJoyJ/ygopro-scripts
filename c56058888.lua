--王宮の陥落
-- 效果：
-- 对方发动永续陷阱卡时才能发动。那张卡的发动和效果无效，并且破坏。
function c56058888.initial_effect(c)
	-- 对方发动永续陷阱卡时才能发动。那张卡的发动和效果无效，并且破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c56058888.condition)
	e1:SetTarget(c56058888.target)
	e1:SetOperation(c56058888.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否满足‘对方发动永续陷阱卡时’的契机
function c56058888.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁的发动者是否为对方、是否为卡片的发动、卡片类型是否为永续陷阱，以及该连锁是否可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_TRAP+TYPE_CONTINUOUS and Duel.IsChainNegatable(ev)
end
-- 定义效果的目标处理函数，用于进行可行性检查并向系统宣告无效和破坏的操作信息
function c56058888.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统宣告该效果包含‘使发动无效’的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若目标卡片可被破坏且与效果有关联，则向系统宣告该效果包含‘破坏’的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果的处理函数，执行无效发动并破坏的操作
function c56058888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡片仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
