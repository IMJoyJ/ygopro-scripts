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
	-- 设置②效果的发动条件：通过aux.exccon限定这张卡送去墓地的回合不能发动该效果。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：通过aux.bfgcost将墓地中的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14386013.drtg)
	e2:SetOperation(c14386013.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：确认手牌中有可丢弃的卡后，丢弃1张手卡作为发动代价。
function c14386013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己手牌存在至少1张可丢弃的卡（且不包含这张卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手牌选1张可丢弃的卡丢弃（作为发动代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果的检索过滤器：可加入手卡，且是「通灵盘」或恶魔族·8星怪兽。
function c14386013.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(94212438) or (c:IsRace(RACE_FIEND) and c:IsLevel(8)))
end
-- 定义①效果的发动目标函数：确认卡组·墓地存在符合条件的卡，并设定加入手卡的操作信息。
function c14386013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组·墓地存在至少1张符合条件的卡（「通灵盘」或恶魔族·8星怪兽）。
	if chk==0 then return Duel.IsExistingMatchingCard(c14386013.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设定操作信息：本次效果将1张卡从卡组·墓地加入手牌（用于后续检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义①效果处理函数：让玩家从卡组·墓地选择1张符合条件的卡加入手牌，并向对方展示。
function c14386013.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1张符合条件的卡（受王家长眠之谷影响的卡不可选）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14386013.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的过滤器：是「通灵盘」或「死之信息」字段的卡，且可以返回卡组。
function c14386013.drfilter(c)
	return (c:IsCode(94212438) or c:IsSetCard(0x1c)) and c:IsAbleToDeck()
end
-- 定义②效果的发动目标函数：确认自己可以抽卡，且手牌·墓地存在符合条件的卡。
function c14386013.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 同时确认手牌·墓地存在至少1张符合条件的「通灵盘」或「死之信息」卡。
		and Duel.IsExistingMatchingCard(c14386013.drfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 将效果的对象玩家设为自己，用于后续抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设定操作信息：本次效果将有卡返回卡组（用于后续检测）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义②效果处理函数：选择任意数量符合条件的卡放回卡组底，然后抽取相同数量的卡。
function c14386013.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象玩家（即自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取自己手牌·墓地中所有符合条件的「通灵盘」/「死之信息」卡（排除王家长眠之谷影响）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c14386013.drfilter),p,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- 显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外检查函数，要求所选卡的卡名互不相同（同名卡最多1张）。
	aux.GCheckAdditional=aux.dncheck
	-- 从符合条件的卡中选择任意数量（至少1张，且卡名各不相同，数量上限为卡组张数）。
	local sg=g:SelectSubGroup(p,aux.TRUE,false,1,Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
	-- 清除额外检查函数，避免影响后续选择。
	aux.GCheckAdditional=nil
	if sg then
		-- 将选择返回卡组的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-p,sg)
		-- 将选择的卡按玩家喜欢的顺序放回卡组底，并返回实际放回的数量。
		local ct=aux.PlaceCardsOnDeckBottom(p,sg)
		if ct==0 then return end
		-- 中断当前效果，使随后的抽卡处理与返回卡组分开，避免错失时点。
		Duel.BreakEffect()
		-- 自己抽取与返回卡组数量相同的卡。
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
