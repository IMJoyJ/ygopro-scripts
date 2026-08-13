--きまぐれ軍貫握り
-- 效果：
-- 这张卡也能把手卡1只「舍利军贯」给对方观看来发动。
-- ①：从卡组把3只「军贯」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。把「舍利军贯」给人观看发动的场合，加入手卡的怪兽由自己来选。
-- ②：把墓地的这张卡除外，以自己墓地3只「军贯」怪兽为对象才能发动。那些怪兽加入卡组。那之后，自己从卡组抽1张。这个效果在这张卡送去墓地的回合不能发动。
function c24393683.initial_effect(c)
	-- 这张卡也能把手卡1只「舍利军贯」给对方观看来发动。①：从卡组把3只「军贯」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。把「舍利军贯」给人观看发动的场合，加入手卡的怪兽由自己来选。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c24393683.cost)
	e1:SetTarget(c24393683.target)
	e1:SetOperation(c24393683.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地3只「军贯」怪兽为对象才能发动。那些怪兽加入卡组。那之后，自己从卡组抽1张。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24393683,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（aux.exccon）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24393683.tdtg)
	e2:SetOperation(c24393683.tdop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：筛选手卡中卡名为「舍利军贯」（卡号24639891）且未公开的卡。
function c24393683.cfilter(c)
	return c:IsCode(24639891) and not c:IsPublic()
end
-- 发动时的追加处理：若手卡存在未公开的「舍利军贯」，询问玩家是否将其展示给对方确认；展示后标记e的Label为1（由自己选卡），否则为0（由对方选卡）。
function c24393683.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得自己手卡中所有满足cfilter条件的卡（未公开的「舍利军贯」）。
	local g=Duel.GetMatchingGroup(c24393683.cfilter,tp,LOCATION_HAND,0,nil)
	-- 若存在符合条件的「舍利军贯」且玩家选择“是”，则执行展示分支；否则直接标记为不展示。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24393683,0)) then  --"是否从手卡展示「舍利军贯」发动？"
		-- 显示“请选择给对方确认的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的手卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 展示手卡后洗切自己的手卡，防止手卡顺序信息泄露。
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 定义过滤函数：筛选卡组中“军贯”字段的怪兽卡，且能够加入手卡。
function c24393683.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x166) and c:IsAbleToHand()
end
-- ①效果的发动条件：卡组中存在至少3只符合条件的“军贯”怪兽；满足后设置效果操作信息为从卡组将1张卡加入手卡（不取对象）。
function c24393683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己卡组中所有满足thfilter条件的“军贯”怪兽。
	local g=Duel.GetMatchingGroup(c24393683.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>=3 end
	-- 设置操作信息：效果将把1张卡从卡组加入手卡（对象不确定，用于检索相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果处理：从卡组选出3只“军贯”怪兽给对方确认；若发动时展示了「舍利军贯」，则由自己选择1只，否则由对方选择1只；被选择的怪兽加入自己手卡，未被选中的卡留在卡组（相当于回到卡组）。
function c24393683.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有符合条件的“军贯”怪兽卡。
	local g=Duel.GetMatchingGroup(c24393683.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 显示“请选择给对方确认的卡”的选择提示，准备从卡组选出3只展示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将自己从卡组选出的3只“军贯”怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		local p=1-tp
		if e:GetLabel()==1 then p=tp end
		-- 显示“请选择要加入手卡的卡”的选择提示，让有权选择的玩家选择1只。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(p,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选中的“军贯”怪兽加入其持有者（自己）的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 定义过滤函数：筛选墓地中“军贯”字段的怪兽卡，且能够返回卡组。
function c24393683.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x166) and c:IsAbleToDeck()
end
-- ②效果的目标处理：以自己墓地3只符合条件的“军贯”怪兽为对象，并设置返回卡组和抽卡的操作信息。
function c24393683.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24393683.tdfilter(chkc) end
	-- ②效果的发动条件：自己可以抽1张卡，且自己墓地存在至少3只可作为对象返回卡组的“军贯”怪兽。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c24393683.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3只符合条件的“军贯”怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24393683.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将选中的对象卡返回卡组，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：效果处理后将让tp玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：把对象怪兽返回持有者卡组（洗切），确认有卡返回后，中断效果处理，然后自己抽1张卡。
function c24393683.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该连锁的对象卡中仍然与效果关联的卡（去除已离场等原因无法处理的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将对象卡返回持有者卡组（以洗切方式），由效果造成。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得刚刚被送回卡组的实际卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果返回卡组的卡中有卡确实在主卡组，则洗切卡组（防止顺序信息泄露）。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使抽卡在返回卡组之后独立处理（正确体现“那之后”）。
		Duel.BreakEffect()
		-- 让自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
