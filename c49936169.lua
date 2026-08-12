--U.A.ロッカールーム
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只「超级运动员」怪兽或者「方程式运动员」怪兽为对象才能发动。那只怪兽回到持有者手卡，自己回复500基本分。那之后，以下效果可以适用。
-- ●手卡的「超级运动员」怪兽或者「方程式运动员」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
function c49936169.initial_effect(c)
	-- ①：以自己的场上·墓地1只「超级运动员」怪兽或者「方程式运动员」怪兽为对象才能发动。那只怪兽回到持有者手卡，自己回复500基本分。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,49936169+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49936169.target)
	e1:SetOperation(c49936169.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「超级运动员」或「方程式运动员」怪兽（包括场上正面表示或墓地中的怪兽）
function c49936169.filter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果处理时选择目标：从自己场上或墓地选择1只符合条件的怪兽作为对象
function c49936169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c49936169.filter(chkc) end
	-- 检查是否满足发动条件：确认自己场上或墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c49936169.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c49936169.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置目标参数为500，用于后续回复LP
	Duel.SetTargetParam(500)
	-- 设置效果处理信息：自己回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 过滤函数，用于筛选手卡中满足条件的「超级运动员」或「方程式运动员」怪兽（未公开且可送入卡组）
function c49936169.cfilter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
end
-- 效果处理函数：将目标怪兽送入手牌并回复LP，之后询问是否将手卡中的怪兽送回卡组并抽卡
function c49936169.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽送入手牌，并确认其在手牌中
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取设置的目标参数（即500）
		local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 回复玩家基本分，若未成功则中断效果处理
		if Duel.Recover(tp,d,REASON_EFFECT)<=0 then return end
		-- 检索满足条件的手卡怪兽组
		local tg=Duel.GetMatchingGroup(c49936169.cfilter,tp,LOCATION_HAND,0,nil)
		-- 检查是否可以抽卡并询问玩家是否发动后续效果
		if #tg<=0 or not Duel.IsPlayerCanDraw(tp) or not Duel.SelectYesNo(tp,aux.Stringid(49936169,0)) then return end  --"是否选手卡回到卡组并抽卡？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择任意数量满足条件的怪兽作为对象
		local g=Duel.SelectMatchingCard(tp,c49936169.cfilter,tp,LOCATION_HAND,0,1,63,nil)
		if g:GetCount()==0 then return end
		-- 向对方确认所选怪兽的卡面信息
		Duel.ConfirmCards(1-tp,g)
		-- 将所选怪兽送入卡组并洗切
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 手动洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		if ct>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 从卡组抽与送回卡组数量相同的卡
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
