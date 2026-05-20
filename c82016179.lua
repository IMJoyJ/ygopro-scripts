--森羅の施し
-- 效果：
-- 从卡组抽3张卡。那之后，把包含1张名字带有「森罗」的卡的手卡2张卡给对方观看，用喜欢的顺序回到卡组上面。手卡没有名字带有「森罗」的卡的场合，手卡全部给对方观看，用喜欢的顺序回到卡组上面。「森罗的施舍」在1回合只能发动1张。
function c82016179.initial_effect(c)
	-- 从卡组抽3张卡。那之后，把包含1张名字带有「森罗」的卡的手卡2张卡给对方观看，用喜欢的顺序回到卡组上面。手卡没有名字带有「森罗」的卡的场合，手卡全部给对方观看，用喜欢的顺序回到卡组上面。「森罗的施舍」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,82016179+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c82016179.target)
	e1:SetOperation(c82016179.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与操作信息设置
function c82016179.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为3
	Duel.SetTargetParam(3)
	-- 设置当前连锁的操作信息为玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	-- 设置当前连锁的操作信息为玩家将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,2)
end
-- 效果处理的执行函数
function c82016179.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家因效果抽3张卡，并判断是否成功抽了3张
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		-- 洗切该玩家的手卡
		Duel.ShuffleHand(p)
		-- 中断当前效果，使之后的效果处理与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 获取玩家手卡中可以送回卡组的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if g:GetCount()>1 and g:IsExists(Card.IsSetCard,1,nil,0x90) then
			-- 提示玩家选择第一张要送回卡组的卡（必须是「森罗」卡）
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg1=g:FilterSelect(p,Card.IsSetCard,1,1,nil,0x90)
			-- 提示玩家选择第二张要送回卡组的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg2=g:Select(p,1,1,sg1:GetFirst())
			sg1:Merge(sg2)
			-- 将选中的2张手卡给对方玩家确认
			Duel.ConfirmCards(1-p,sg1)
			-- 将选中的2张手卡以喜欢的顺序放回卡组最上方
			aux.PlaceCardsOnDeckTop(p,sg1)
		else
			-- 获取玩家的全部手卡
			local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
			-- 将全部手卡给对方玩家确认
			Duel.ConfirmCards(1-p,hg)
			-- 将全部手卡以喜欢的顺序放回卡组最上方
			aux.PlaceCardsOnDeckTop(p,hg)
		end
	end
end
