--ピースリア
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。给这张卡放置1个拼图指示物（最多4个）。那之后，可以让这张卡的拼图指示物数量的以下效果适用。
-- ●1个：从卡组选1只怪兽在卡组最上面放置。
-- ●2个：自己从卡组抽1张。
-- ●3个：从卡组把1只怪兽加入手卡。
-- ●4个：从卡组选1张卡加入手卡。
function c49776811.initial_effect(c)
	c:EnableCounterPermit(0x5f)
	c:SetCounterLimit(0x5f,4)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。给这张卡放置1个拼图指示物（最多4个）。那之后，可以让这张卡的拼图指示物数量的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(c49776811.cttg)
	e2:SetOperation(c49776811.ctop)
	c:RegisterEffect(e2)
end
-- 设置连锁处理信息，确定将要放置1个拼图指示物。
function c49776811.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and e:GetHandler():IsCanAddCounter(0x5f,1) end
	-- 设置操作信息为放置指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x5f)
end
-- 处理拼图友爱天使战斗后放置指示物并根据指示物数量发动对应效果。
function c49776811.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x5f,1)
		local ct=c:GetCounter(0x5f)
		-- 获取卡组中所有怪兽卡片的集合。
		local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
		-- 当指示物数量为1时，询问玩家是否从卡组选择一只怪兽放到卡组最上方。
		if ct==1 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,0)) then  --"是否从卡组选1只怪兽在卡组最上面放置？"
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要放置在卡组最上方的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(49776811,4))  --"请选择要放置在卡组最上面的怪兽"
			local g=dg:Select(tp,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				-- 将玩家卡组洗切。
				Duel.ShuffleDeck(tp)
				-- 将选中的怪兽移动到卡组最上方。
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				-- 确认玩家卡组最上方的一张卡。
				Duel.ConfirmDecktop(tp,1)
			end
		end
		-- 当指示物数量为2时，询问玩家是否从卡组抽一张卡。
		if ct==2 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(49776811,1)) then  --"是否从卡组抽1张？"
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 让玩家从卡组抽一张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		-- 获取卡组中所有可以加入手牌的怪兽卡片集合。
		local mg=Duel.GetMatchingGroup(c49776811.mfilter,tp,LOCATION_DECK,0,nil)
		-- 当指示物数量为3时，询问玩家是否从卡组选择一只怪兽加入手牌。
		if ct==3 and mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,2)) then  --"是否从卡组把1只怪兽加入手卡？"
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local g=mg:Select(tp,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡片送入玩家手牌。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方确认玩家从卡组选择加入手牌的卡片。
				Duel.ConfirmCards(1-tp,g)
			end
		end
		-- 获取卡组中所有可以加入手牌的卡片集合。
		local cg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil)
		-- 当指示物数量为4时，询问玩家是否从卡组选择一张卡加入手牌。
		if ct==4 and cg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,3)) then  --"是否从卡组选1张卡加入手卡？"
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local g=cg:Select(tp,1,1,nil)
			if g:GetCount()>0 then
				g:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
				-- 将选中的卡片送入玩家手牌。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 定义用于筛选可以加入手牌的怪兽卡片的过滤函数。
function c49776811.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
