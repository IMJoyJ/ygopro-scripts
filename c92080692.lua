--見切りの極意
-- 效果：
-- ①：和对方墓地的卡同名的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
function c92080692.initial_effect(c)
	-- ①：和对方墓地的卡同名的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c92080692.condition)
	e1:SetTarget(c92080692.target)
	e1:SetOperation(c92080692.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方发动了怪兽的效果或魔法·陷阱卡，且对方墓地存在同名卡，且该连锁的发动可以被无效
function c92080692.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 检查对方墓地是否存在至少1张与当前发动效果的卡同名的卡
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_GRAVE,1,nil,re:GetHandler():GetCode())
		-- 检查当前连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 设置效果处理的预估操作信息（无效与破坏）
function c92080692.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可被破坏且与效果存在联系，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使发动无效并破坏
function c92080692.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且发动的卡与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
