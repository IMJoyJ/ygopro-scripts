--ディザーム
-- 效果：
-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。魔法卡的发动无效并破坏。
function c26834022.initial_effect(c)
	-- 效果发动时，将此卡注册为连锁处理效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c26834022.condition)
	e1:SetTarget(c26834022.target)
	e1:SetOperation(c26834022.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中名字带有「剑斗兽」且可以送回卡组的卡片
function c26834022.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 效果发动条件，判断是否为魔法卡的发动且可以被无效
function c26834022.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 魔法卡的发动且可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 效果处理目标设定，设置连锁处理中需要无效和破坏的目标
function c26834022.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c26834022.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理中需要无效的卡片
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理中需要破坏的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，执行将手牌中的「剑斗兽」卡送回卡组并无效魔法卡发动和破坏
function c26834022.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张手牌
	local g=Duel.SelectMatchingCard(tp,c26834022.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 向对方确认选择的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡片送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 使魔法卡发动无效并判断是否可以破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏魔法卡的发动对象
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
