--ダーク・オカルティズム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从自己的卡组·墓地选1张「通灵盘」或者1只恶魔族·8星怪兽加入手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地的「通灵盘」以及「死之信息」卡之中选任意数量（同名卡最多1张），用喜欢的顺序回到卡组下面。那之后，自己从卡组抽出回去的数量。这个效果在这张卡送去墓地的回合不能发动。
function c14386013.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从自己的卡组·墓地选1张「通灵盘」或者1只恶魔族·8星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14386013,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14386013)
	e1:SetCost(c14386013.cost)
	e1:SetTarget(c14386013.target)
	e1:SetOperation(c14386013.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地的「通灵盘」以及「死之信息」卡之中选任意数量（同名卡最多1张），用喜欢的顺序回到卡组下面。那之后，自己从卡组抽出回去的数量。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14386013,1))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,14386014)
	-- 效果发动时，检查是否为这张卡送去墓地的回合，若是则效果不能发动。
	e2:SetCondition(aux.exccon)
	-- 效果发动时，将此卡从墓地除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14386013.drtg)
	e2:SetOperation(c14386013.drop)
	c:RegisterEffect(e2)
end
-- 效果的费用处理函数，用于处理丢弃手卡的费用。
function c14386013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作，丢弃原因包含费用和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索满足条件的卡的过滤函数，用于判断是否为「通灵盘」或恶魔族8星怪兽。
function c14386013.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(94212438) or (c:IsRace(RACE_FIEND) and c:IsLevel(8)))
end
-- 效果的发动时处理函数，用于设置效果发动时的处理目标。
function c14386013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的卡组和墓地是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c14386013.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理信息，表示将要处理1张来自卡组或墓地的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果的发动处理函数，用于处理效果的发动。
function c14386013.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组和墓地中选择满足条件的1张卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14386013.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的卡的过滤函数，用于判断是否为「通灵盘」或「死之信息」卡。
function c14386013.drfilter(c)
	return (c:IsCode(94212438) or c:IsSetCard(0x1c)) and c:IsAbleToDeck()
end
-- 效果的发动时处理函数，用于设置效果发动时的处理目标。
function c14386013.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查玩家手牌和墓地中是否存在满足条件的卡。
		and Duel.IsExistingMatchingCard(c14386013.drfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理信息，表示将要处理1张来自手牌或墓地的卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果的发动处理函数，用于处理效果的发动。
function c14386013.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取满足条件的卡组，包括手牌和墓地中的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c14386013.drfilter),p,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要回到卡组的卡。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	-- 设置额外的卡名检查条件，确保所选卡名不重复。
	aux.GCheckAdditional=aux.dncheck
	-- 从满足条件的卡中选择任意数量的卡，确保卡名不重复。
	local sg=g:SelectSubGroup(p,aux.TRUE,false,1,Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
	-- 取消设置额外的卡名检查条件。
	aux.GCheckAdditional=nil
	if sg then
		-- 向对方确认选中的卡。
		Duel.ConfirmCards(1-p,sg)
		-- 将选中的卡放回卡组底部。
		local ct=aux.PlaceCardsOnDeckBottom(p,sg)
		if ct==0 then return end
		-- 中断当前效果处理，使后续处理视为不同时处理。
		Duel.BreakEffect()
		-- 从卡组抽选中卡的数量的卡。
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
