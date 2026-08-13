--繁華の花笑み
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己墓地的「繁华的花笑」的数量＋3张从自己卡组上面翻开。那之中有3种类（怪兽·魔法·陷阱）的卡的场合，选那之内的1张加入手卡，剩下的卡送去墓地。没有的场合，翻开的卡全部回到卡组。
function c32887445.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己墓地的「繁华的花笑」的数量＋3张从自己卡组上面翻开。那之中有3种类（怪兽·魔法·陷阱）的卡的场合，选那之内的1张加入手卡，剩下的卡送去墓地。没有的场合，翻开的卡全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32887445+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32887445.target)
	e1:SetOperation(c32887445.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的合法条件检查与操作信息设定：计算墓地同名卡数量，翻开对应张数，若存在可加入手卡的卡则允许发动，并设定将1张卡从卡组加入手卡的处理信息。
function c32887445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己墓地中卡名「繁华的花笑」的数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,32887445)
	-- 获取自己卡组最上方（墓地同名卡数量+3）张卡。
	local g=Duel.GetDecktopGroup(tp,ct+3)
	-- 检查可否从卡组送墓相应张数，且翻开的卡中存在可加入手卡的卡；满足则发动合法。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct+3) and g:FilterCount(Card.IsAbleToHand,nil)>0 end
	-- 设定本次连锁的处理信息：将要处理的是把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时翻开卡组顶端对应张数，若包含怪兽·魔法·陷阱三种类则选1张加入手卡，其余送墓；否则翻开的卡全部回到卡组并洗切。
function c32887445.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次计算自己墓地中卡名「繁华的花笑」的数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,32887445)
	-- 再次确认玩家能否从卡组送墓ct+3张，若不能则直接终止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,ct+3) then return end
	-- 向双方确认翻开卡组顶端的ct+3张卡。
	Duel.ConfirmDecktop(tp,ct+3)
	-- 获取这ct+3张翻开的卡作为组对象。
	local g=Duel.GetDecktopGroup(tp,ct+3)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) and g:IsExists(Card.IsType,1,nil,TYPE_SPELL) and g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		-- 禁用接下来的自动洗切检测，因为后续会从卡组取走部分卡并可能改变卡组顺序，需要手动控制洗切。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手卡的卡（弹出选择框）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsAbleToHand() then
			-- 将选择的卡以效果原因加入持有者手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方确认加入手卡的这张卡。
			Duel.ConfirmCards(1-tp,tc)
			-- 洗切手卡（因为加入了卡，手动洗牌重置状态）。
			Duel.ShuffleHand(tp)
		else
			-- 若选中的卡不能加入手卡，则将其以规则原因送去墓地。
			Duel.SendtoGrave(tc,REASON_RULE)
		end
		g:RemoveCard(tc)
		-- 将剩余翻开的卡以效果+翻开的原因一起送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 当没有3种类卡时，将翻开的卡全部返回卡组并洗切。
		Duel.ShuffleDeck(tp)
	end
end
