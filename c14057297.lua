--死なばもろとも
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方手卡各自是3张以上的场合才能发动。双方玩家各自让手卡全部用喜欢的顺序回到卡组下面，自己失去这个效果让双方回到卡组的卡数量×300基本分。那之后，双方玩家各自从卡组抽5张。
function c14057297.initial_effect(c)
	-- 创建效果，设置效果分类为回卡组和抽卡，效果类型为发动，时点为自由时点，限制一回合只能发动1次，条件为双方手牌都不少于3张，目标函数为c14057297.target，发动函数为c14057297.activate
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
-- 效果条件函数，判断是否满足发动条件
function c14057297.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 双方手牌数量都不少于3张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=3
end
-- 效果目标函数，判断是否可以抽卡
function c14057297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽5张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5) end
	-- 获取当前玩家手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 设置操作信息，将当前玩家手牌全部送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息，双方各抽5张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
-- 效果发动函数，执行效果处理
function c14057297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前玩家手牌数量为0则返回
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,LOCATION_HAND)==0 then return end
	local p=tp
	local st=0
	for i=1,2 do
		-- 获取当前玩家手牌组
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将手牌全部送入卡组顶端
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		-- 获取实际操作的卡组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then
			st=st+ct
			-- 对当前玩家卡组最上方的卡进行排序
			Duel.SortDecktop(p,p,ct)
			for j=1,ct do
				-- 获取当前玩家卡组最上方的卡
				local mg=Duel.GetDecktopGroup(p,1)
				-- 将卡移动到卡组底端
				Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
			end
		end
		p=1-p
	end
	-- 获取当前玩家当前LP
	local lp=Duel.GetLP(tp)
	-- 扣除玩家LP，扣除数量为双方送入卡组的卡数乘以300
	Duel.SetLP(tp,lp-st*300)
	-- 如果当前玩家LP大于0
	if Duel.GetLP(tp)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 当前玩家抽5张卡
		Duel.Draw(tp,5,REASON_EFFECT)
		-- 对方玩家抽5张卡
		Duel.Draw(1-tp,5,REASON_EFFECT)
	end
end
