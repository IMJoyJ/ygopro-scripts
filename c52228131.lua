--パリィ
-- 效果：
-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。陷阱卡的发动无效并破坏。
function c52228131.initial_effect(c)
	-- 从手卡把1张名字带有「剑斗兽」的卡回到卡组。陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c52228131.condition)
	e1:SetTarget(c52228131.target)
	e1:SetOperation(c52228131.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否为名字带有「剑斗兽」的卡且能够返回卡组。
function c52228131.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 发动条件：当有陷阱卡发动，且该发动可以被无效时，此卡才能发动。
function c52228131.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：对方发动的连锁必须是魔法·陷阱卡的发动且为陷阱类型，同时该连锁的发动可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 发动时的目标设定：确认手牌存在可回卡组的剑斗兽卡，并登记无效并破坏的对象为发动中的陷阱卡。
function c52228131.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：己方手牌中是否存在至少1张满足『剑斗兽字段且可返回卡组』的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52228131.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 登记操作信息：将当前连锁（该陷阱卡的发动）标记为无效对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：若该陷阱卡可被破坏且仍与发动效果关联，则将其标记为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：从手牌选择1张剑斗兽卡返回卡组，然后无效发动中的陷阱卡并将其破坏。
function c52228131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌选出1张满足条件的剑斗兽卡（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c52228131.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡送回持有者卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 判定无效是否成功，且发动中的陷阱卡仍与效果关联（未离开原区域）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的陷阱卡（若之前条件满足）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
