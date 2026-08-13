--星遺物に蠢く罠
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地的卡、自己场上的表侧表示的卡、除外的自己的卡之中选「蠢动于星遗物的陷阱」以外的「星遗物」卡5种类各1张，加入持有者卡组洗切。那之后，自己从卡组抽2张。
function c16329071.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地的卡、自己场上的表侧表示的卡、除外的自己的卡之中选「蠢动于星遗物的陷阱」以外的「星遗物」卡5种类各1张，加入持有者卡组洗切。那之后，自己从卡组抽2张。
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
-- 筛选条件：属于「星遗物」字段、卡名不是「蠢动于星遗物的陷阱」、位于手卡或墓地或是表侧表示、且可以返回卡组的卡。
function c16329071.filter(c)
	return c:IsSetCard(0xfe) and not c:IsCode(16329071) and (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
-- 发动条件判定：当处于发动时点（chk==0）时，要求自己能够抽2张卡，且满足条件的「星遗物」卡的种类数不少于5。
function c16329071.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己的手卡、墓地、场上（表侧表示）及除外区中取得所有满足 c16329071.filter 的卡，作为可供选择的集合。
	local g=Duel.GetMatchingGroup(c16329071.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	-- 在发动时的合法性检查中，作为条件之一：自己必须能够抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and g:GetClassCount(Card.GetCode)>=5 end
	-- 设置操作信息：本次效果处理中包含将5张卡返回持有者卡组的处理（目标未指定，数量为5）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,0,0)
	-- 设置操作信息：本次效果处理中包含自己抽2张卡的处理（目标为自己，数量为2）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：重新取得符合条件的卡（并排除王家长眠之谷的影响），选择5种不同卡名各1张，向对方确认手卡后送回持有者卡组洗切；若5张均成功返回卡组，则自己抽2张。
function c16329071.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 重新取得符合条件的卡，并用 aux.NecroValleyFilter 过滤掉受王家长眠之谷影响而无法从墓地或场上离开的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16329071.filter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetCode)<5 then return end
	-- 显示选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置附加选择限制：所选的卡必须卡名互不相同，以实现“5种类各1张”。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从候选卡中选出5张卡名互不相同的卡（最少5张、最多5张）。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,5,5)
	-- 清除附加选择限制，恢复默认选择条件。
	aux.GCheckAdditional=nil
	local cg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if cg:GetCount()>0 then
		-- 如果选择中包含手卡，则向对方玩家展示这些手卡，以确认选择。
		Duel.ConfirmCards(1-tp,cg)
	end
	-- 将选中的卡以效果送回持有者卡组，并设定返回卡组后需要洗切（SEQ_DECKSHUFFLE）。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才被送回卡组的实际卡片组。
	local og=Duel.GetOperatedGroup()
	-- 如果实际被送回卡组的卡中有卡片位于卡组，则洗切该卡组。
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果处理，使随后的抽卡处理与之前的回卡组处理分开展开，避免错失时点。
		Duel.BreakEffect()
		-- 自己从卡组抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
