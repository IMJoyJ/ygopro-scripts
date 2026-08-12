--悪魔嬢ロリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地的卡以及除外的自己的卡之中以3张或者6张通常陷阱卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，回去的卡每有3张，自己从卡组抽1张。
-- ②：这张卡以外的怪兽被解放的场合或者对方的效果让通常陷阱卡被送去自己墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c50699850.initial_effect(c)
	-- ①：从自己墓地的卡以及除外的自己的卡之中以3张或者6张通常陷阱卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，回去的卡每有3张，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,50699850)
	e1:SetTarget(c50699850.tdtg)
	e1:SetOperation(c50699850.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的怪兽被解放的场合或者对方的效果让通常陷阱卡被送去自己墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
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
-- 过滤满足条件的通常陷阱卡，包括墓地和除外区的卡，且能被效果选为目标
function c50699850.tdfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:GetType()==TYPE_TRAP
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 判断选择的卡组数量是否为3或6张
function c50699850.fselect(sg)
	return sg:GetCount()==3 or sg:GetCount()==6
end
-- 设置①效果的目标卡组并计算抽卡数量
function c50699850.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的墓地和除外区的通常陷阱卡组
	local g=Duel.GetMatchingGroup(c50699850.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 检查玩家是否可以发动此效果（至少能抽1张卡且有3张以上可选卡）
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #g>=3 end
	local max=3
	-- 如果可以抽2张卡，则最大选择数量为6张
	if Duel.IsPlayerCanDraw(tp,2) then max=6 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,c50699850.fselect,false,3,max)
	-- 设置本次效果的目标卡组
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	-- 设置操作信息：自己抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,sg:GetCount()//3)
end
-- 处理①效果的发动后操作，包括将卡送回卡组、排序并抽卡
function c50699850.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标卡组送回卡组顶部
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- 获取实际被操作的卡组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		-- 对玩家卡组最上方的卡进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取玩家卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组底部
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 根据送回卡组的卡数计算并执行抽卡
		Duel.Draw(tp,ct//3,REASON_EFFECT)
	end
end
-- 判断被解放的卡是否为怪兽且不是从魔法陷阱区离开
function c50699850.cfilter1(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断是否满足②效果发动条件：有怪兽被解放且非自身
function c50699850.stcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50699850.cfilter1,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 判断被送去墓地的卡是否为通常陷阱卡且由对方效果造成
function c50699850.cfilter2(c,tp)
	return c:GetType()==TYPE_TRAP and c:IsControler(tp) and c:GetReason()&REASON_EFFECT>0 and c:GetReasonPlayer()==1-tp
end
-- 判断是否满足②效果发动条件：对方的效果使通常陷阱卡送去墓地
function c50699850.stcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50699850.cfilter2,1,nil,tp)
end
-- 过滤可盖放的通常陷阱卡
function c50699850.stfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 设置②效果的目标卡并提示选择
function c50699850.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50699850.stfilter(chkc) end
	-- 检查是否有满足条件的墓地通常陷阱卡可选
	if chk==0 then return Duel.IsExistingTarget(c50699850.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c50699850.stfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标卡盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 处理②效果的发动后操作，包括将卡盖放到场上
function c50699850.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
