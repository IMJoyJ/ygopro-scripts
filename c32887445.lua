--繁華の花笑み
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己墓地的「繁华的花笑」的数量＋3张从自己卡组上面翻开。那之中有3种类（怪兽·魔法·陷阱）的卡的场合，选那之内的1张加入手卡，剩下的卡送去墓地。没有的场合，翻开的卡全部回到卡组。
function c32887445.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌、卡组送去墓地和检索，设置效果类型为发动，设置发动时点为自由连锁，设置发动次数限制为1次，设置效果目标函数和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32887445+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32887445.target)
	e1:SetOperation(c32887445.activate)
	c:RegisterEffect(e1)
end
-- 效果目标函数，用于判断是否可以发动效果
function c32887445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计玩家墓地中「繁华的花笑」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,32887445)
	-- 获取玩家卡组最上方的ct+3张卡
	local g=Duel.GetDecktopGroup(tp,ct+3)
	-- 若chk为0，则返回玩家是否可以将卡组顶端ct+3张卡送去墓地且这些卡中存在可以加入手牌的卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct+3) and g:FilterCount(Card.IsAbleToHand,nil)>0 end
	-- 设置效果处理时的操作信息，指定将要处理1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行效果的主要逻辑
function c32887445.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 统计玩家墓地中「繁华的花笑」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,32887445)
	-- 检查玩家是否可以将卡组顶端ct+3张卡送去墓地，若不能则返回
	if not Duel.IsPlayerCanDiscardDeck(tp,ct+3) then return end
	-- 确认玩家卡组最上方的ct+3张卡
	Duel.ConfirmDecktop(tp,ct+3)
	-- 获取玩家卡组最上方的ct+3张卡
	local g=Duel.GetDecktopGroup(tp,ct+3)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) and g:IsExists(Card.IsType,1,nil,TYPE_SPELL) and g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		-- 禁用后续操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsAbleToHand() then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认选中的卡
			Duel.ConfirmCards(1-tp,tc)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
		else
			-- 将选中的卡以规则原因送去墓地
			Duel.SendtoGrave(tc,REASON_RULE)
		end
		g:RemoveCard(tc)
		-- 将剩余的卡以效果和翻开原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将玩家卡组洗切
		Duel.ShuffleDeck(tp)
	end
end
