--悪魔嬢ロリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地的卡以及除外的自己的卡之中以3张或者6张通常陷阱卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，回去的卡每有3张，自己从卡组抽1张。
-- ②：这张卡以外的怪兽被解放的场合或者对方的效果让通常陷阱卡被送去自己墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c50699850.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己墓地的卡以及除外的自己的卡之中以3张或者6张通常陷阱卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，回去的卡每有3张，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,50699850)
	e1:SetTarget(c50699850.tdtg)
	e1:SetOperation(c50699850.tdop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡以外的怪兽被解放的场合或者对方的效果让通常陷阱卡被送去自己墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,50699851)
	e2:SetCondition(c50699850.stcon1)
	e2:SetTarget(c50699850.sttg)
	e2:SetOperation(c50699850.stop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c50699850.stcon2)
	c:RegisterEffect(e3)
end
-- 筛选可作为①对象并返回卡组的卡：自己墓地或表侧除外的通常陷阱，且满足能回卡组、能成为效果对象。
function c50699850.tdfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:GetType()==TYPE_TRAP
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 选择组必须为3张或6张，以对应“3张或者6张通常陷阱卡”。
function c50699850.fselect(sg)
	return sg:GetCount()==3 or sg:GetCount()==6
end
-- 效果①发动时的目标与操作设定：从符合条件的通常陷阱中选取3或6张，设定回卡组和抽卡。
function c50699850.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地及除外区中所有满足tdfilter的卡（作为可选对象集合）。
	local g=Duel.GetMatchingGroup(c50699850.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查发动条件：玩家至少可抽1张且可选卡不少于3张。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #g>=3 end
	local max=3
	-- 若玩家可抽2张，则将可选择的卡数上限由3提高到6（即可选6张时抽2张）。
	if Duel.IsPlayerCanDraw(tp,2) then max=6 end
	-- 显示提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,c50699850.fselect,false,3,max)
	-- 将选中的卡组设为当前连锁的对象（该效果为取对象效果）。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：这些卡将被返回卡组，数量为选中数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	-- 设置操作信息：抽卡，预期抽卡数为返回卡组数除以3。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,sg:GetCount()//3)
end
-- 效果①处理：先将对象卡返回卡组最上方，再让玩家排序并依次移入卡组最下方，最后抽相应数量的卡。
function c50699850.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡组（即发动时选中的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍与效果关联的对象卡返回持有者卡组最上方（暂存，随后移动到底部）。
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- 取得上一步实际被返回卡组的卡组。
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		-- 由玩家对返回卡组顶端的卡进行排序，以决定回卡组下面的顺序。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 取卡组最上方1张卡（组），准备移动。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将这张卡移动至卡组最下方；循环执行，使排序后的卡按顺序置于卡组底。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
		-- 中断当前效果，使“回卡组”与“抽卡”作为不同时点处理，对应“那之后”。
		Duel.BreakEffect()
		-- 自己从卡组抽ct//3张卡（每3张抽1张）。
		Duel.Draw(tp,ct//3,REASON_EFFECT)
	end
end
-- 判断被解放的卡是否为来自怪兽区域的怪兽（排除来自魔陷区的卡），用于“怪兽被解放”的触发条件。
function c50699850.cfilter1(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②的触发条件（解放分支）：本卡以外的怪兽被解放。
function c50699850.stcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50699850.cfilter1,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 判断该卡是否为通常陷阱控制者为自己，且因对方效果被送去墓地（原因玩家为对方且原因为效果）。
function c50699850.cfilter2(c,tp)
	return c:GetType()==TYPE_TRAP and c:IsControler(tp) and c:GetReason()&REASON_EFFECT>0 and c:GetReasonPlayer()==1-tp
end
-- ②的触发条件（陷阱分支）：对方效果导致自己场上的通常陷阱被送去墓地。
function c50699850.stcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50699850.cfilter2,1,nil,tp)
end
-- 判断卡是否为通常陷阱且可以盖放（可被盖放到魔陷区）。
function c50699850.stfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 效果②发动时的目标与操作设定：选择自己墓地1张通常陷阱卡作为对象，并设置盖放操作信息。
function c50699850.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50699850.stfilter(chkc) end
	-- 检查发动条件：自己墓地存在至少1张可盖放的通常陷阱。
	if chk==0 then return Duel.IsExistingTarget(c50699850.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示提示，让玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张符合条件的通常陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c50699850.stfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：该对象卡将离开墓地（被盖放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②处理：将仍与效果关联的对象卡在自己场上盖放。
function c50699850.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡（即选择的墓地通常陷阱）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以里侧表示盖放到玩家tp的魔法陷阱区（对应“那张卡在自己场上盖放”）。
		Duel.SSet(tp,tc)
	end
end
