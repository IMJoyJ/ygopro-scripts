--死なばもろとも
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方手卡各自是3张以上的场合才能发动。双方玩家各自让手卡全部用喜欢的顺序回到卡组下面，自己失去这个效果让双方回到卡组的卡数量×300基本分。那之后，双方玩家各自从卡组抽5张。
function c14057297.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：双方手卡各自是3张以上的场合才能发动。双方玩家各自让手卡全部用喜欢的顺序回到卡组下面，自己失去这个效果让双方回到卡组的卡数量×300基本分。那之后，双方玩家各自从卡组抽5张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14057297+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c14057297.condition)
	e1:SetTarget(c14057297.target)
	e1:SetOperation(c14057297.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判断函数：检查双方手卡数量是否满足发动条件。
function c14057297.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数是否大于等于3且对方手卡数是否大于等于3。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=3
end
-- 定义发动时目标与合法性检查函数：进行发动前的可发动性判定并设置效果处理信息。
function c14057297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查双方玩家是否都能各抽5张卡，若有一方不能抽则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5) end
	-- 获取双方玩家手卡的所有卡，作为本次效果要送回卡组的对象集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 设置“回卡组”的操作信息：对象为双方所有手牌，数量为这些卡的总数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置“抽卡”的操作信息：不指定具体对象，双方玩家各抽5张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
-- 定义效果处理函数：双方手牌按玩家选择顺序回卡组底、扣除LP，之后各自抽5张。
function c14057297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 保护性判断：若双方手牌总数为0则直接结束本次效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,LOCATION_HAND)==0 then return end
	local p=tp
	local st=0
	for i=1,2 do
		-- 获取当前玩家p的全部手牌。
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将该玩家的手牌全部以效果送回持有者卡组最顶端（临时放置，后续再按顺序移回底部）。
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- 获取上一步实际被送回卡组的卡片组，用于后续统计数量及排序。
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then
			st=st+ct
			-- 让该玩家对自身卡组最上方ct张卡进行排序，决定回到卡组底部的顺序。
			Duel.SortDecktop(p,p,ct)
			for j=1,ct do
				-- 取出当前卡组最上方的1张卡，即玩家排序后的第一张卡。
				local mg=Duel.GetDecktopGroup(p,1)
				-- 将这张卡移动到卡组最底部，从而实现“按喜欢的顺序回到卡组下面”。
				Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
			end
		end
		p=1-p
	end
	-- 获取发动玩家当前的LP数值。
	local lp=Duel.GetLP(tp)
	-- 将发动玩家的LP扣除双方回到卡组的卡数量乘以300的数值。
	Duel.SetLP(tp,lp-st*300)
	-- 若发动玩家扣LP后LP仍大于0，则继续处理后续抽卡；否则因LP为0而不再执行。
	if Duel.GetLP(tp)>0 then
		-- 中断当前效果处理，使后续抽卡不视为与之前操作同一次处理，避免错失时点。
		Duel.BreakEffect()
		-- 发动玩家从卡组抽5张卡。
		Duel.Draw(tp,5,REASON_EFFECT)
		-- 对方玩家从卡组抽5张卡。
		Duel.Draw(1-tp,5,REASON_EFFECT)
	end
end
