--地縛波
-- 效果：
-- 自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方的魔法·陷阱卡的发动无效并破坏。
function c29934351.initial_effect(c)
	-- 效果原文内容：自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29934351.condition)
	e1:SetTarget(c29934351.target)
	e1:SetOperation(c29934351.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查场上是否有名字带有「地缚神」的表侧表示怪兽
function c29934351.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1021)
end
-- 规则层面作用：判断是否为对方发动的魔法·陷阱卡，且该连锁可以被无效，并且自己场上存在名字带有「地缚神」的表侧表示怪兽
function c29934351.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否为对方发动的魔法·陷阱卡，且该连锁可以被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 规则层面作用：检查自己场上是否存在名字带有「地缚神」的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c29934351.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：设置连锁处理时的操作信息，包括使对方魔法·陷阱卡无效和破坏
function c29934351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置使对方魔法·陷阱卡无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：设置破坏对方魔法·陷阱卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面作用：执行效果，使对方魔法·陷阱卡无效并破坏
function c29934351.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否成功使对方魔法·陷阱卡无效且该卡与效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：破坏对方魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
