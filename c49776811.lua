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
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。给这张卡放置1个拼图指示物（最多4个）。那之后，可以让这张卡的拼图指示物数量的以下效果适用。●1个：从卡组选1只怪兽在卡组最上面放置。●2个：自己从卡组抽1张。●3个：从卡组把1只怪兽加入手卡。●4个：从卡组选1张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(c49776811.cttg)
	e2:SetOperation(c49776811.ctop)
	c:RegisterEffect(e2)
end
c49776811.mentioned_counter={
	[0x5f]=true,
}
-- 效果发动条件检测：确认这张卡的战斗目标是对方怪兽，且这张卡可以放置1个拼图指示物
function c49776811.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and e:GetHandler():IsCanAddCounter(0x5f,1) end
	-- 设置本次连锁的操作信息为放置指示物效果（放置1个拼图指示物），用于王家长眠之谷等卡的发动检测
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x5f)
end
-- 效果处理：给这张卡放置1个拼图指示物，然后根据当前拼图指示物的数量（1~4个）询问玩家是否适用对应的效果
function c49776811.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x5f,1)
		local ct=c:GetCounter(0x5f)
		-- 检索自己卡组中满足条件的怪兽（作为1个指示物效果的选择范围）
		local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
		-- 若拼图指示物为1个且卡组存在怪兽，询问玩家是否从卡组选1只怪兽在卡组最上面放置
		if ct==1 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,0)) then  --"是否从卡组选1只怪兽在卡组最上面放置？"
			-- 中断当前效果处理，使之后的处理视为不同时处理（避免错过时点）
			Duel.BreakEffect()
			-- 提示玩家「请选择要放置在卡组最上面的怪兽」
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(49776811,4))  --"请选择要放置在卡组最上面的怪兽"
			local g=dg:Select(tp,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				-- 洗切自己的卡组
				Duel.ShuffleDeck(tp)
				-- 将选择的怪兽移动到卡组最上面
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				-- 确认自己卡组最上面的1张卡
				Duel.ConfirmDecktop(tp,1)
			end
		end
		-- 若拼图指示物为2个且自己可以抽卡，询问玩家是否从卡组抽1张
		if ct==2 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(49776811,1)) then  --"是否从卡组抽1张？"
			-- 中断当前效果处理，使之后的抽卡视为不同时处理（避免错过时点）
			Duel.BreakEffect()
			-- 自己以效果从卡组抽1张
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		-- 检索自己卡组中可以加入手卡的怪兽（作为3个指示物效果的选择范围）
		local mg=Duel.GetMatchingGroup(c49776811.mfilter,tp,LOCATION_DECK,0,nil)
		-- 若拼图指示物为3个且卡组存在可加入手卡的怪兽，询问玩家是否从卡组把1只怪兽加入手卡
		if ct==3 and mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,2)) then  --"是否从卡组把1只怪兽加入手卡？"
			-- 中断当前效果处理，使之后的处理视为不同时处理（避免错过时点）
			Duel.BreakEffect()
			-- 提示玩家「请选择要加入手牌的卡」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local g=mg:Select(tp,1,1,nil)
			if g:GetCount()>0 then
				-- 把选择的怪兽以效果加入持有者的手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的那张卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
		-- 检索自己卡组中可以加入手卡的卡（作为4个指示物效果的选择范围）
		local cg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil)
		-- 若拼图指示物为4个且卡组存在可加入手卡的卡，询问玩家是否从卡组选1张卡加入手卡
		if ct==4 and cg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49776811,3)) then  --"是否从卡组选1张卡加入手卡？"
			-- 中断当前效果处理，使之后的处理视为不同时处理（避免错过时点）
			Duel.BreakEffect()
			-- 提示玩家「请选择要加入手牌的卡」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local g=cg:Select(tp,1,1,nil)
			if g:GetCount()>0 then
				g:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
				-- 把选择的卡以效果加入持有者的手卡（不给对方确认）
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 过滤条件：怪兽卡且可以加入手卡
function c49776811.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
