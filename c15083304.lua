--未界域の危険地帯
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己从卡组抽3张。那之后，从手卡把包含「未界域」卡1张以上的2张卡丢弃。手卡没有「未界域」卡的场合，手卡全部公开，回到卡组。
function c15083304.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15083304+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c15083304.target)
	e1:SetOperation(c15083304.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查玩家是否可以抽3张卡
function c15083304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家是否可以抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 效果作用：设置连锁对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁对象参数为3
	Duel.SetTargetParam(3)
	-- 效果作用：设置操作信息为抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果作用：判断组中是否存在包含「未界域」的卡
function c15083304.gselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x11e)
end
-- 效果原文内容：①：自己从卡组抽3张。那之后，从手卡把包含「未界域」卡1张以上的2张卡丢弃。手卡没有「未界域」卡的场合，手卡全部公开，回到卡组。
function c15083304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行抽卡效果并判断是否成功抽3张
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		-- 效果作用：洗切玩家手牌
		Duel.ShuffleHand(p)
		-- 效果作用：中断当前效果处理
		Duel.BreakEffect()
		-- 效果作用：获取玩家手牌组
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if #g>=2 and g:IsExists(Card.IsSetCard,1,nil,0x11e) then
			-- 效果作用：提示玩家选择丢弃的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)
			local g1=g:SelectSubGroup(tp,c15083304.gselect,false,2,2)
			-- 效果作用：将选中的卡送入墓地
			Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)
		else
			-- 效果作用：向对方确认玩家手牌
			Duel.ConfirmCards(1-p,g)
			-- 效果作用：将玩家手牌送回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
