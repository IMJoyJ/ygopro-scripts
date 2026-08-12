--DDDの人事権
-- 效果：
-- ①：从自己的手卡·场上·墓地的「DD」怪兽以及自己的灵摆区域的「DD」卡之中选合计3张回到持有者卡组。那之后，可以从卡组把2只「DD」怪兽加入手卡。
function c72648577.initial_effect(c)
	-- ①：从自己的手卡·场上·墓地的「DD」怪兽以及自己的灵摆区域的「DD」卡之中选合计3张回到持有者卡组。那之后，可以从卡组把2只「DD」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c72648577.target)
	e1:SetOperation(c72648577.operation)
	c:RegisterEffect(e1)
end
-- 过滤手卡·场上·墓地的「DD」怪兽以及灵摆区域的「DD」卡，且能回到卡组
function c72648577.filter(c)
	return c:IsSetCard(0xaf) and c:IsAbleToDeck()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
		and (c:IsType(TYPE_MONSTER) or c:IsLocation(LOCATION_PZONE))
end
-- 过滤卡组中可以加入手卡的「DD」怪兽
function c72648577.thfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的合法性检测与操作信息设置
function c72648577.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、场上、墓地、灵摆区域是否存在合计3张满足条件的「DD」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72648577.filter,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND,0,3,nil) end
	-- 设置操作信息为：预计将3张卡回到持有者的卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理的执行函数，处理回到卡组以及后续的检索手牌
function c72648577.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡、场上、墓地、灵摆区域满足条件且不受「王家长眠之谷」影响的「DD」卡
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c72648577.filter),tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil)
	if g:GetCount()<3 then return end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,3,3,nil)
	local cg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	-- 给对方玩家确认选中的手卡
	Duel.ConfirmCards(1-tp,cg)
	-- 将选中的3张卡送回持有者卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被送回卡组（或额外卡组）的卡片组
	local og=Duel.GetOperatedGroup()
	if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
	-- 获取卡组中可以加入手卡的「DD」怪兽
	local dg=Duel.GetMatchingGroup(c72648577.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查卡组中是否存在至少2只「DD」怪兽，并询问玩家是否选择加入手卡
	if dg:GetCount()>1 and Duel.SelectYesNo(tp,aux.Stringid(72648577,0)) then  --"卡组检索"
		-- 中断当前效果处理，使后续的检索手卡与之前的回卡组不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=dg:Select(tp,2,2,nil)
		-- 将选中的2只「DD」怪兽加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tg)
	else
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			-- 若未进行检索，则对卡组进行洗牌
			Duel.ShuffleDeck(tp)
		end
	end
end
