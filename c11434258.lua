--蛇龍の枷鎖
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方的场上·墓地1只连接怪兽为对象才能发动。自己从卡组抽出那只怪兽的连接标记的数量。那之后，自己手卡是2张以上的场合，选那之内的2张用喜欢的顺序回到卡组最下面。
function c11434258.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方的场上·墓地1只连接怪兽为对象才能发动。自己从卡组抽出那只怪兽的连接标记的数量。那之后，自己手卡是2张以上的场合，选那之内的2张用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11434258+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11434258.drtg)
	e1:SetOperation(c11434258.drop)
	c:RegisterEffect(e1)
end
-- 定义滤函数：指定卡片必须是连接怪兽，且当前玩家能够抽取该怪兽连接标记数量的卡。
function c11434258.filter(c,tp)
	-- 判断该卡是否为连接怪兽，并确认玩家能够抽取其连接标记数量的卡。
	return c:IsType(TYPE_LINK) and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 效果发动时的目标选择与参数设定：检索对方场上·墓地满足条件的连接怪兽，选择1只为对象，记录玩家与抽卡数量。
function c11434258.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c11434258.filter(chkc,tp) end
	-- 发动合法性检查：确认对方场上·墓地存在至少1只符合条件的连接怪兽且玩家能抽对应数量的卡。
	if chk==0 then return Duel.IsExistingTarget(c11434258.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
	-- 向发动者显示“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者从对方场上·墓地选择1只符合条件的连接怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c11434258.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	local tc=g:GetFirst()
	local ct=tc:GetLink()
	-- 将效果的对象玩家设置为发动者自身，表示抽卡玩家是发动者。
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设置为选定连接怪兽的连接标记数量，即需要抽的卡数。
	Duel.SetTargetParam(ct)
	-- 登记操作信息：本次连锁将执行抽卡，预计抽卡数为ct，用于连锁相关检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：抽取记录数量的卡；若抽卡后手牌数大于1，则选择其中2张按任意顺序放回卡组最下面。
function c11434258.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出连锁信息中记录的对象玩家（抽卡玩家）和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 进行抽卡；若实际抽卡成功且该玩家手牌数大于1，则继续处理放回卡组的操作。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(p,LOCATION_HAND,0)>1 then
		-- 获取该玩家手卡中所有能够返回卡组的卡。
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if g:GetCount()==0 then return end
		-- 洗切该玩家手牌，避免选择时暴露手牌顺序信息。
		Duel.ShuffleHand(p)
		-- 中断当前效果，使后续的选卡放回卡组处理视为不同时点，避免错时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要返回卡组的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,2,2,nil)
		-- 让玩家将选中的2张卡以任意顺序放置到卡组最下面。
		aux.PlaceCardsOnDeckBottom(p,sg)
	end
end
