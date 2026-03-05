--星遺物に蠢く罠
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地的卡、自己场上的表侧表示的卡、除外的自己的卡之中选「蠢动于星遗物的陷阱」以外的「星遗物」卡5种类各1张，加入持有者卡组洗切。那之后，自己从卡组抽2张。
function c16329071.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16329071+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c16329071.target)
	e1:SetOperation(c16329071.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足星遗物卡组、非此卡、位置在手牌或墓地或场上表侧表示、可送入卡组的卡
function c16329071.filter(c)
	return c:IsSetCard(0xfe) and not c:IsCode(16329071) and (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
-- 效果作用：判断是否可以发动此效果，条件为玩家可以抽2张卡且满足条件的卡有5种以上
function c16329071.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取满足filter条件的卡组
	local g=Duel.GetMatchingGroup(c16329071.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	-- 效果作用：判断玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and g:GetClassCount(Card.GetCode)>=5 end
	-- 效果作用：设置操作信息为将5张卡送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,0,0)
	-- 效果作用：设置操作信息为玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果原文内容：①：从自己的手卡·墓地的卡、自己场上的表侧表示的卡、除外的自己的卡之中选「蠢动于星遗物的陷阱」以外的「星遗物」卡5种类各1张，加入持有者卡组洗切。那之后，自己从卡组抽2张。
function c16329071.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取满足NecroValleyFilter过滤条件的卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16329071.filter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetCode)<5 then return end
	-- 效果作用：提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 效果作用：从满足条件的卡中选择5张不重复卡名的卡
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,5,5)
	-- 效果作用：取消额外检查条件
	aux.GCheckAdditional=nil
	local cg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if cg:GetCount()>0 then
		-- 效果作用：确认对方玩家看到被选中的手牌
		Duel.ConfirmCards(1-tp,cg)
	end
	-- 效果作用：将选中的卡送入卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：获取实际被操作的卡组
	local og=Duel.GetOperatedGroup()
	-- 效果作用：若送入卡组的卡中有进入卡组的，则洗切卡组
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
