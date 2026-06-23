--鋼核の輝き
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。对方的魔法·陷阱卡的发动无效并破坏。
function c34545235.initial_effect(c)
	-- 记录此卡具有「核成兽的钢核」这张卡的卡号
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看发动。对方的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34545235.condition)
	e1:SetCost(c34545235.cost)
	e1:SetTarget(c34545235.target)
	e1:SetOperation(c34545235.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方发动魔法或陷阱卡且该连锁可以被无效
function c34545235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方不是发动者且发动的是魔法或陷阱卡且该连锁可以被无效
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：检查手牌中是否存在未公开的「核成兽的钢核」
function c34545235.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 支付费用：选择并确认一张手牌中的「核成兽的钢核」，然后洗切手牌
function c34545235.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在未公开的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c34545235.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认给对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手牌中的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c34545235.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手牌洗切
	Duel.ShuffleHand(tp)
end
-- 设置效果处理信息：使对方魔法或陷阱卡发动无效
function c34545235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使对方魔法或陷阱卡发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息：破坏对方的魔法或陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动效果：使对方魔法或陷阱卡发动无效并破坏
function c34545235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方魔法或陷阱卡发动无效且该卡仍存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方的魔法或陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
