--バウンドリンク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只连接怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，自己从卡组抽出那个连接标记的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组下面。
function c51335426.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51335426+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51335426.target)
	e1:SetOperation(c51335426.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的连接怪兽，包括墓地和场上的怪兽，且能回到额外卡组并可以抽卡。
function c51335426.filter(c,tp)
	-- 效果作用：判断目标是否为场上的连接怪兽或墓地中的连接怪兽，并且可以特殊召唤到额外卡组，同时玩家可以抽相应数量的卡。
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_LINK) and c:IsAbleToExtra() and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 效果原文内容：①：以自己的场上·墓地1只连接怪兽为对象才能发动。
function c51335426.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c51335426.filter(chkc,tp) end
	-- 效果作用：检查是否存在满足条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51335426.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 效果作用：提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择符合条件的目标怪兽。
	local g=Duel.SelectTarget(tp,c51335426.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 效果作用：设置操作信息，表示将目标怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 效果作用：设置连锁对象玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁对象参数为所选怪兽的连接标记数。
	Duel.SetTargetParam(g:GetFirst():GetLink())
	-- 效果作用：设置操作信息，表示进行抽卡处理。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetFirst():GetLink())
	-- 效果作用：设置操作信息，表示将手牌送回卡组底部。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,g:GetFirst():GetLink())
end
-- 效果原文内容：那只怪兽回到持有者的额外卡组，自己从卡组抽出那个连接标记的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组下面。
function c51335426.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLink()
	-- 效果作用：判断目标怪兽是否有效，并将其送回额外卡组，且确保其在额外卡组中。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 效果作用：进行抽卡处理，如果成功抽到指定数量的卡，则继续执行后续操作。
		if Duel.Draw(p,ct,REASON_EFFECT)==ct then
			-- 效果作用：获取当前玩家手牌中可以送回卡组的卡。
			local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
			if g:GetCount()<ct then return end
			-- 效果作用：洗切当前玩家的手牌。
			Duel.ShuffleHand(p)
			-- 效果作用：中断当前效果处理，使之后的效果视为不同时处理。
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要返回卡组的卡。
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=g:Select(p,ct,ct,nil)
			-- 效果作用：将选中的手牌按顺序放回卡组底部。
			aux.PlaceCardsOnDeckBottom(p,sg)
		end
	end
end
