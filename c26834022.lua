--ディザーム
-- 效果：
-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。魔法卡的发动无效并破坏。
function c26834022.initial_effect(c)
	-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。魔法卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c26834022.condition)
	e1:SetTarget(c26834022.target)
	e1:SetOperation(c26834022.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：手卡中存在名字带有「剑斗兽」且能够返回卡组的卡。
function c26834022.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 效果发动条件：仅在对方发动魔法卡且该连锁可以被无效时才能发动。
function c26834022.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查正在发动的效果是否为魔法卡的发动（类型为魔法且为发动型效果），并且该连锁可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 发动时的目标处理：确认手卡是否有符合条件剑斗兽卡，并宣告要无效并破坏的魔法卡。
function c26834022.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张符合筛选条件的「剑斗兽」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c26834022.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：本次效果将无效连锁的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的魔法卡可被破坏且与效果关联，则设置操作信息：本次效果将破坏该魔法卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先从手卡选择1张「剑斗兽」卡返回卡组，再无效并破坏对方发动的魔法卡。
function c26834022.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，要求选择1张要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手卡选择1张满足条件的名字带有「剑斗兽」的卡。
	local g=Duel.SelectMatchingCard(tp,c26834022.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡送回持有者卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 确认连锁发动被无效成功，且该魔法卡仍然与效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的魔法卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
