--おジャマッチング
-- 效果：
-- ①：从手卡以及自己场上的表侧表示的卡之中把1张「扰乱」卡送去墓地才能发动。从自己的卡组·墓地选和那张卡卡名不同的1只「扰乱」怪兽和1只「武装龙」怪兽加入手卡。那之后，可以把这个效果加入手卡的1只怪兽召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c38395123.initial_effect(c)
	-- 效果①：从手卡以及自己场上的表侧表示的卡之中把1张「扰乱」卡送去墓地才能发动。从自己的卡组·墓地选和那张卡卡名不同的1只「扰乱」怪兽和1只「武装龙」怪兽加入手卡。那之后，可以把这个效果加入手卡的1只怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38395123.cost)
	e1:SetTarget(c38395123.target)
	e1:SetOperation(c38395123.activate)
	c:RegisterEffect(e1)
	-- 效果②：自己主要阶段把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38395123.drtg)
	e2:SetOperation(c38395123.drop)
	c:RegisterEffect(e2)
end
-- 设置效果标签为1，表示可以发动效果①
function c38395123.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 检查手卡或场上的「扰乱」卡是否满足送去墓地的条件，并且卡组或墓地是否存在满足条件的「扰乱」怪兽和「武装龙」怪兽
function c38395123.cfilter(c,tp)
	return c:IsSetCard(0xf) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 检查卡组或墓地是否存在与所选卡不同名的「扰乱」怪兽
		and Duel.IsExistingMatchingCard(c38395123.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c,c:GetCode())
		-- 检查卡组或墓地是否存在「武装龙」怪兽
		and Duel.IsExistingMatchingCard(c38395123.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c)
end
-- 过滤条件：类型为怪兽、种族为「扰乱」、卡名不等于指定卡名、可以加入手卡
function c38395123.filter1(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 过滤条件：类型为怪兽、种族为「武装龙」、可以加入手卡
function c38395123.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x111) and c:IsAbleToHand()
end
-- 效果①的发动条件判断与处理：检查是否存在满足条件的「扰乱」卡，选择并送去墓地
function c38395123.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查手卡或场上的「扰乱」卡是否存在满足条件的卡
		return Duel.IsExistingMatchingCard(c38395123.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「扰乱」卡
	local g=Duel.SelectMatchingCard(tp,c38395123.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	e:SetLabelObject(g:GetFirst())
	-- 将所选卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置效果处理信息：将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理：检索满足条件的「扰乱」怪兽和「武装龙」怪兽并加入手牌，可选择召唤其中一只
function c38395123.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	-- 获取卡组或墓地满足条件的「扰乱」怪兽组
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38395123.filter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,sc,sc:GetCode())
	-- 获取卡组或墓地满足条件的「武装龙」怪兽组
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38395123.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,sc)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的「扰乱」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=g1:Select(tp,1,1,nil)
	-- 提示玩家选择要加入手牌的「武装龙」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local gg=g2:Select(tp,1,1,nil)
	g:Merge(gg)
	-- 将选中的2张卡加入手牌
	if g:GetCount()==2 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取实际加入手牌的卡组，筛选出可召唤的怪兽
		local og=Duel.GetOperatedGroup():Filter(Card.IsSummonable,nil,true,nil)
		-- 询问玩家是否选择召唤加入手牌的怪兽
		if og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38395123,0)) then  --"是否选加入手卡的怪兽召唤？"
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sg=og:Select(tp,1,1,nil):GetFirst()
			-- 进行召唤操作
			Duel.Summon(tp,sg,true,nil)
		end
	end
end
-- 过滤条件：场上表侧表示的「扰乱」怪兽、可以返回卡组
function c38395123.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf) and c:IsAbleToDeck()
end
-- 效果②的发动条件判断：检查是否可以抽卡并是否存在3张满足条件的除外的「扰乱」怪兽
function c38395123.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c38395123.tdfilter(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否存在3张满足条件的除外的「扰乱」怪兽
		and Duel.IsExistingTarget(c38395123.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张满足条件的除外的「扰乱」怪兽
	local g=Duel.SelectTarget(tp,c38395123.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置效果处理信息：将3张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置效果处理信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理：将选中的卡返回卡组并洗切，然后抽1张卡
function c38395123.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组，筛选出与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标卡返回卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡组
	local g=Duel.GetOperatedGroup()
	-- 若返回卡组的卡中有位于卡组的卡，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
