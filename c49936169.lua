--U.A.ロッカールーム
-- 效果：
-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只「超级运动员」怪兽或者「方程式运动员」怪兽为对象才能发动。那只怪兽回到持有者手卡，自己回复500基本分。那之后，以下效果可以适用。
-- ●手卡的「超级运动员」怪兽或者「方程式运动员」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
function c49936169.initial_effect(c)
	-- 这个卡名在规则上也当作「方程式运动员」卡使用。这个卡名的卡在1回合只能发动1张。①：以自己的场上·墓地1只「超级运动员」怪兽或者「方程式运动员」怪兽为对象才能发动。那只怪兽回到持有者手卡，自己回复500基本分。那之后，以下效果可以适用。●手卡的「超级运动员」怪兽或者「方程式运动员」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
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
-- 筛选可成为对象的目标：自己场上表侧表示或墓地的「超级运动员」／「方程式运动员」怪兽，且满足能加入手牌的条件。
function c49936169.filter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 发动时进行条件检测、选择对象，并设定返回手牌与回复LP的效果信息。
function c49936169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c49936169.filter(chkc) end
	-- 效果发动时点检查自己场上表侧表示或墓地是否存在至少1只符合条件的「超级运动员」／「方程式运动员」怪兽，没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c49936169.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上表侧表示或墓地选择1只符合条件的怪兽作为效果对象，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c49936169.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的对象登记为“返回手牌”的效果处理目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置本连锁的回复LP数值参数为500，供效果处理时读取。
	Duel.SetTargetParam(500)
	-- 登记本效果包含回复500基本分的信息，用于连锁检测和发动判定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 筛选手牌中「超级运动员」／「方程式运动员」怪兽，要求非公开状态且能返回卡组，用于后续任意数量洗回卡组。
function c49936169.cfilter(c)
	return c:IsSetCard(0xb2,0x107) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToDeck()
end
-- 效果处理时，先将对象怪兽返回持有者手牌，回复500LP；然后询问是否将手牌中符合条件的任意数量怪兽给对方确认并洗回卡组，再抽出相同数量。
function c49936169.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽返回持有者手牌，并确认返回成功且当前位于手牌，才继续后续处理。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 读取本连锁预先设定的回复LP数值（500）。
		local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 回复500基本分；若回复未成功（如被无效或变为伤害）则终止后续处理。
		if Duel.Recover(tp,d,REASON_EFFECT)<=0 then return end
		-- 取得手牌中所有符合条件的「超级运动员」／「方程式运动员」怪兽，作为可洗回卡组的候选。
		local tg=Duel.GetMatchingGroup(c49936169.cfilter,tp,LOCATION_HAND,0,nil)
		-- 若没有可洗回卡组的手牌怪兽、不能抽卡或玩家选择“否”，则结束效果，不进行后续洗牌抽卡。
		if #tg<=0 or not Duel.IsPlayerCanDraw(tp) or not Duel.SelectYesNo(tp,aux.Stringid(49936169,0)) then return end  --"是否选手卡回到卡组并抽卡？"
		-- 中断当前效果处理，使后续的洗牌抽卡与前面的回手、回复视为不同时点，避免错过时点。
		Duel.BreakEffect()
		-- 显示“请选择要返回卡组的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手牌中任意选择1至63张符合条件的「超级运动员」／「方程式运动员」怪兽用于返回卡组。
		local g=Duel.SelectMatchingCard(tp,c49936169.cfilter,tp,LOCATION_HAND,0,1,63,nil)
		if g:GetCount()==0 then return end
		-- 将选中的手牌怪兽给对手确认，满足“给对方观看”的要求。
		Duel.ConfirmCards(1-tp,g)
		-- 将选中的怪兽以洗牌方式返回持有者卡组，返回实际送回的数量。
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切己方卡组，使返回的卡随机混入卡组。
		Duel.ShuffleDeck(tp)
		if ct>0 then
			-- 再次中断效果处理，将抽卡处理与之前的洗牌动作分离，使抽卡时点正确触发。
			Duel.BreakEffect()
			-- 抽取与洗回卡组数量相同的卡。
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
