--未界域の危険地帯
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己从卡组抽3张。那之后，从手卡把包含「未界域」卡1张以上的2张卡丢弃。手卡没有「未界域」卡的场合，手卡全部公开，回到卡组。
function c15083304.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己从卡组抽3张。那之后，从手卡把包含「未界域」卡1张以上的2张卡丢弃。手卡没有「未界域」卡的场合，手卡全部公开，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15083304+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c15083304.target)
	e1:SetOperation(c15083304.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的检测与目标设置
function c15083304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己是否可以从卡组抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为3
	Duel.SetTargetParam(3)
	-- 设置当前处理的连锁的操作信息为抽卡（从自己卡组抽3张卡）
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 检查选中的卡片组中是否包含至少1张「未界域」卡
function c15083304.gselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x11e)
end
-- 效果处理：执行抽3张卡，之后根据手牌是否有「未界域」卡来选择丢弃或将全部手牌公开并回到卡组
function c15083304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，并检查是否成功抽了3张卡
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
		-- 中断当前效果，使后续处理与抽卡视为不同时处理
		Duel.BreakEffect()
		-- 获取玩家的全部手牌
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if #g>=2 and g:IsExists(Card.IsSetCard,1,nil,0x11e) then
			-- 提示玩家选择需要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local g1=g:SelectSubGroup(tp,c15083304.gselect,false,2,2)
			-- 以丢弃的形式将选中的2张手牌送去墓地
			Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)
		else
			-- 将全部手牌公开给对方玩家确认
			Duel.ConfirmCards(1-p,g)
			-- 将全部手牌送回持有者卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
