--きまぐれ軍貫握り
-- 效果：
-- 这张卡也能把手卡1只「舍利军贯」给对方观看来发动。
-- ①：从卡组把3只「军贯」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。把「舍利军贯」给人观看发动的场合，加入手卡的怪兽由自己来选。
-- ②：把墓地的这张卡除外，以自己墓地3只「军贯」怪兽为对象才能发动。那些怪兽加入卡组。那之后，自己从卡组抽1张。这个效果在这张卡送去墓地的回合不能发动。
function c24393683.initial_effect(c)
	-- ①：从卡组把3只「军贯」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。把「舍利军贯」给人观看发动的场合，加入手卡的怪兽由自己来选。
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
	-- 设置效果不能在该卡送去墓地的回合发动
	e2:SetCondition(aux.exccon)
	-- 设置效果发动时需要把此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24393683.tdtg)
	e2:SetOperation(c24393683.tdop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的「舍利军贯」
function c24393683.cfilter(c)
	return c:IsCode(24639891) and not c:IsPublic()
end
-- 判断是否选择展示手卡中的「舍利军贯」发动效果，若选择则确认一张卡并洗切手牌，设置标签为1
function c24393683.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取手卡中满足条件的「舍利军贯」卡片组
	local g=Duel.GetMatchingGroup(c24393683.cfilter,tp,LOCATION_HAND,0,nil)
	-- 判断是否选择展示手卡中的「舍利军贯」发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24393683,0)) then  --"是否从手卡展示「舍利军贯」发动？"
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 过滤卡组中可加入手牌的「军贯」怪兽
function c24393683.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x166) and c:IsAbleToHand()
end
-- 设置效果发动时的处理目标为卡组中满足条件的怪兽
function c24393683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中满足条件的「军贯」怪兽卡片组
	local g=Duel.GetMatchingGroup(c24393683.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>=3 end
	-- 设置效果处理时将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 发动效果时从卡组确认3张「军贯」怪兽，由对方选择1张加入手牌，若选择展示「舍利军贯」则由自己选择
function c24393683.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的「军贯」怪兽卡片组
	local g=Duel.GetMatchingGroup(c24393683.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,sg)
		local p=1-tp
		if e:GetLabel()==1 then p=tp end
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(p,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 过滤墓地中可返回卡组的「军贯」怪兽
function c24393683.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x166) and c:IsAbleToDeck()
end
-- 设置效果发动时的处理目标为墓地中满足条件的怪兽
function c24393683.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24393683.tdfilter(chkc) end
	-- 判断是否满足发动条件，即可以抽卡且墓地有3只满足条件的怪兽
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c24393683.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张墓地中的「军贯」怪兽作为处理对象
	local g=Duel.SelectTarget(tp,c24393683.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置效果处理时将选择的怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果处理时自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 发动效果时将选择的3只怪兽返回卡组，若其中有卡返回卡组则洗切卡组，然后自己抽1张卡
function c24393683.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡片组并筛选出与效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将目标卡片组返回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一次操作实际处理的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若返回卡组的卡片中有进入卡组的，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
