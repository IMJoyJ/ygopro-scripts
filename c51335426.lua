--バウンドリンク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只连接怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，自己从卡组抽出那个连接标记的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组下面。
function c51335426.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的场上·墓地1只连接怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，自己从卡组抽出那个连接标记的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组下面。
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
-- 定义选择对象的过滤函数：筛选出位于自己场上表侧表示或自己墓地、类型为连接怪兽、能够返回额外卡组，并且自己可以抽出其连接标记数量卡片的连接怪兽。
function c51335426.filter(c,tp)
	-- 返回筛选条件：对象卡必须是（在墓地或场上表侧表示）的连接怪兽，能够送去额外卡组，且当前玩家可以抽取等于其连接标记数量的卡。
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_LINK) and c:IsAbleToExtra() and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 效果发动前的目标处理：检查是否存在合法对象，选择自己场上·墓地1只连接怪兽作为对象，并设置后续回额外卡组、抽卡以及按数量把手牌回卡组底的操作信息。
function c51335426.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c51335426.filter(chkc,tp) end
	-- 在发动时（非处理时）检查是否存在至少1只满足条件的连接怪兽可以作为对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51335426.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家显示选择提示信息，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上表侧表示或墓地的连接怪兽中选择1只作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51335426.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：将选择的对象卡加入回卡组（额外卡组）分类，数量为1，对象为目标怪兽，供后续相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置当前连锁的对象玩家为自己，用于记录抽卡与回卡组操作的归属玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为对象连接怪兽的连接标记数量，作为后续抽卡数量以及回卡组手牌数量的依据。
	Duel.SetTargetParam(g:GetFirst():GetLink())
	-- 设置操作信息：抽卡分类，预计抽取数量为对象怪兽的连接标记数量，具体抽卡对象在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetFirst():GetLink())
	-- 设置操作信息：回卡组分类，预计需要将相同数量的手牌返回卡组底，具体手牌在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,g:GetFirst():GetLink())
end
-- 效果处理时的操作：将对象连接怪兽返回持有者额外卡组，若成功则抽等于其连接标记数量的卡，抽满后从手牌选择相同数量的卡按玩家喜欢的顺序放回卡组底。
function c51335426.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中保存的对象玩家，即抽卡和回手牌操作的归属玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取连锁中保存的对象怪兽，即被选择返回额外卡组的连接怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLink()
	-- 判断对象怪兽仍与此效果关联，且成功返回持有者额外卡组（通过回卡组效果处理，处理后确认其位于额外卡组），才继续后续抽卡和回卡组处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 只有当实际抽卡数等于需要抽的连接标记数量（即抽卡成功且数量足够）时，才执行后续选择手牌返回卡组底的操作。
		if Duel.Draw(p,ct,REASON_EFFECT)==ct then
			-- 获取该玩家手牌中所有能够返回卡组的卡，作为后续选择放回卡组底的对象集合。
			local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
			if g:GetCount()<ct then return end
			-- 洗切该玩家手牌，确保后续选择手牌时不会因为手牌顺序而影响公平性。
			Duel.ShuffleHand(p)
			-- 中断当前效果处理，错开时点，使后续“选择手牌放回卡组底”的处理与之前的抽卡等效果不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要返回卡组底部的卡片，提示信息为“请选择要返回卡组的卡”。
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=g:Select(p,ct,ct,nil)
			-- 将玩家选择的手牌按照其喜欢的顺序放置到卡组底端。
			aux.PlaceCardsOnDeckBottom(p,sg)
		end
	end
end
