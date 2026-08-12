--王の試練
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：手卡1只「王战」怪兽给对方观看，从卡组把「王战的试练」以外的最多2张「王战」魔法·陷阱卡加入手卡（同名卡最多1张）。那之后，给人观看的卡回到卡组最下面。
function c75448086.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：手卡1只「王战」怪兽给对方观看，从卡组把「王战的试练」以外的最多2张「王战」魔法·陷阱卡加入手卡（同名卡最多1张）。那之后，给人观看的卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,75448086+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c75448086.target)
	e1:SetOperation(c75448086.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中未公开且可以回到卡组的「王战」怪兽
function c75448086.filter1(c)
	return c:IsSetCard(0x134) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 过滤卡组中「王战的试练」以外且可以加入手牌的「王战」魔法·陷阱卡
function c75448086.filter2(c)
	return c:IsSetCard(0x134) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(75448086) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c75448086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可给对方观看的「王战」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75448086.filter1,tp,LOCATION_HAND,0,1,nil)
		-- 检查卡组中是否存在可检索的「王战」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c75448086.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含将卡片送回卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示此效果包含从卡组将卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c75448086.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要展示并返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手牌中1只用于展示的「王战」怪兽
	local g1=Duel.SelectMatchingCard(tp,c75448086.filter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽给对方观看
	Duel.ConfirmCards(1-tp,g1)
	if g1:GetCount()==0 then return end
	-- 获取卡组中所有满足检索条件的「王战」魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(c75448086.filter2,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择最多2张卡名不同的卡片
	local sg=g2:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 如果成功将选择的卡片加入手牌
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 给对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 中断效果连接，使后续的返回卡组处理不与加入手牌同时处理
		Duel.BreakEffect()
		-- 将展示的怪兽卡送回卡组最下面
		Duel.SendtoDeck(g1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
