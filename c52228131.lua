--パリィ
-- 效果：
-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。陷阱卡的发动无效并破坏。
function c52228131.initial_effect(c)
	-- 创建效果，设置效果分类为无效、破坏和回卡组，类型为发动，触发时点为连锁发动，条件为c52228131.condition，目标为c52228131.target，效果处理为c52228131.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c52228131.condition)
	e1:SetTarget(c52228131.target)
	e1:SetOperation(c52228131.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中名字带有「剑斗兽」且可以送回卡组的卡片
function c52228131.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 效果发动条件，判断是否为陷阱卡的发动且可无效
function c52228131.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 陷阱卡的发动且可无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 设置效果处理的目标信息，包括无效和可能的破坏
function c52228131.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c52228131.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，选择并送回卡组一张符合条件的卡，然后无效连锁并可能破坏原卡
function c52228131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c52228131.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 确认对方查看所选卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将所选卡片送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 使连锁发动无效且原卡存在并关联到效果时进行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
