--蛇龍の枷鎖
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方的场上·墓地1只连接怪兽为对象才能发动。自己从卡组抽出那只怪兽的连接标记的数量。那之后，自己手卡是2张以上的场合，选那之内的2张用喜欢的顺序回到卡组最下面。
function c11434258.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：过滤满足条件的连接怪兽
function c11434258.filter(c,tp)
	-- 效果作用：判断目标怪兽是否可以抽卡
	return c:IsType(TYPE_LINK) and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 效果原文内容：①：以对方的场上·墓地1只连接怪兽为对象才能发动。
function c11434258.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c11434258.filter(chkc,tp) end
	-- 效果作用：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c11434258.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
	-- 效果作用：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 效果作用：选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c11434258.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	local tc=g:GetFirst()
	local ct=tc:GetLink()
	-- 效果作用：设置效果的目标玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置效果的目标参数为怪兽的连接数
	Duel.SetTargetParam(ct)
	-- 效果作用：设置效果操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果原文内容：自己从卡组抽出那只怪兽的连接标记的数量。那之后，自己手卡是2张以上的场合，选那之内的2张用喜欢的顺序回到卡组最下面。
function c11434258.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行抽卡并判断手牌数量是否大于2
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(p,LOCATION_HAND,0)>1 then
		-- 效果作用：获取可以回到卡组的卡牌组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if g:GetCount()==0 then return end
		-- 效果作用：洗切玩家手牌
		Duel.ShuffleHand(p)
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local sg=g:Select(p,2,2,nil)
		-- 效果作用：将选中的卡牌放回卡组底部
		aux.PlaceCardsOnDeckBottom(p,sg)
	end
end
