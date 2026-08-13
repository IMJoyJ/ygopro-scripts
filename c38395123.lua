--おジャマッチング
-- 效果：
-- ①：从手卡以及自己场上的表侧表示的卡之中把1张「扰乱」卡送去墓地才能发动。从自己的卡组·墓地选和那张卡卡名不同的1只「扰乱」怪兽和1只「武装龙」怪兽加入手卡。那之后，可以把这个效果加入手卡的1只怪兽召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c38395123.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示的卡之中把1张「扰乱」卡送去墓地才能发动。从自己的卡组·墓地选和那张卡卡名不同的1只「扰乱」怪兽和1只「武装龙」怪兽加入手卡。那之后，可以把这个效果加入手卡的1只怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38395123.cost)
	e1:SetTarget(c38395123.target)
	e1:SetOperation(c38395123.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动代价：把墓地的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38395123.drtg)
	e2:SetOperation(c38395123.drop)
	c:RegisterEffect(e2)
end
-- e1的cost函数：将标签e:SetLabel(1)标记为1并返回true，表示允许发动；真正的选卡送墓代价延迟到target阶段处理。
function c38395123.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 筛选可作为①代价的「扰乱」卡：要求该卡是「扰乱」字段，在手牌或场上表侧表示，可作为cost送墓；并且卡组·墓地中存在可检索的不同名「扰乱」怪兽和「武装龙」怪兽各至少1只，确保代价后处理能成功。
function c38395123.cfilter(c,tp)
	return c:IsSetCard(0xf) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 检查卡组·墓地中是否存在1只与所选送墓「扰乱」卡卡名不同的「扰乱」怪兽，可作为检索对象。
		and Duel.IsExistingMatchingCard(c38395123.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c,c:GetCode())
		-- 检查卡组·墓地中是否存在1只「武装龙」怪兽，可作为检索对象。
		and Duel.IsExistingMatchingCard(c38395123.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c)
end
-- 定义可检索的「扰乱」怪兽条件：怪兽且「扰乱」字段，卡名与作为代价的卡不同，并且能被加入手牌。
function c38395123.filter1(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 定义可检索的「武装龙」怪兽条件：必须是怪兽、「武装龙」字段、能被加入手牌。
function c38395123.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x111) and c:IsAbleToHand()
end
-- e1的target函数：在发动时选择手牌或自己场上表侧表示的1张「扰乱」卡送去墓地作为代价，并将该卡存入标签；同时设置效果操作信息为从卡组·墓地检索2张加入手牌。
function c38395123.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查是否存在满足条件的代价卡（在手牌或自己场上表侧表示中），且该卡送墓后能完成检索，用于发动合法性检查。
		return Duel.IsExistingMatchingCard(c38395123.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp)
	end
	e:SetLabel(0)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌和自己场上表侧表示的卡中选择1张满足cfilter的「扰乱」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c38395123.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的「扰乱」卡送去墓地，作为效果①发动的代价。
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置效果操作信息：预计从卡组·墓地处理2张卡加入手牌（检索目标数量不确定，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- e1的activate函数：根据已送墓的「扰乱」卡，从卡组·墓地各选1只符合条件的「扰乱」怪兽和「武装龙」怪兽加入手牌并展示；若成功加入手牌且其中有可通常召唤的怪兽，则询问玩家是否额外召唤其中1只。
function c38395123.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	-- 获取卡组·墓地中所有满足filter1且不受王家长眠之谷影响的「扰乱」怪兽（排除代价卡本身，即卡名不同），用于选择。
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38395123.filter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,sc,sc:GetCode())
	-- 获取卡组·墓地中所有满足filter2且不受王家长眠之谷影响的「武装龙」怪兽，用于选择。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38395123.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,sc)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家从符合条件的「扰乱」怪兽中选择1张加入手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=g1:Select(tp,1,1,nil)
	-- 提示玩家从符合条件的「武装龙」怪兽中选择1张加入手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local gg=g2:Select(tp,1,1,nil)
	g:Merge(gg)
	-- 若两张卡均已选择且实际加入手牌成功（Duel.SendtoHand返回值大于0），则继续后续处理；否则终止。
	if g:GetCount()==2 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方玩家展示加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
		-- 从实际加入手牌的卡中筛选出满足通常召唤条件的怪兽，用于后续额外召唤。
		local og=Duel.GetOperatedGroup():Filter(Card.IsSummonable,nil,true,nil)
		-- 若存在可通常召唤的怪兽，弹窗询问玩家是否选择其中1只进行召唤。
		if og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38395123,0)) then  --"是否选加入手卡的怪兽召唤？"
			-- 中断当前效果处理，使后续的召唤处理成为一个独立的时点（避免错过时点）。
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sg=og:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽进行不占用通常召唤次数的通常召唤（ignore_count=true）。
			Duel.Summon(tp,sg,true,nil)
		end
	end
end
-- 定义效果②可选对象的条件：表侧表示的「扰乱」怪兽，且可以返回卡组。
function c38395123.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf) and c:IsAbleToDeck()
end
-- e2的target函数：当chkc参数存在时验证单张卡是否为除外的自己的表侧扰乱怪兽；当chk==0时检查玩家能否抽卡以及除外区是否存在至少3只符合条件的「扰乱」怪兽可作为对象。
function c38395123.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c38395123.tdfilter(chkc) end
	-- 效果②发动条件之一：检查玩家tp至少能抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果②发动条件之二：检查除外区是否存在至少3只满足条件且能成为效果对象的自己的「扰乱」怪兽。
		and Duel.IsExistingTarget(c38395123.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡（选择对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己除外区的表侧扰乱怪兽中选择3张作为效果对象，并登记为取对象。
	local g=Duel.SelectTarget(tp,c38395123.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：该效果涉及将3张对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息：该效果涉及玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- e2的activate函数：将仍有效的对象卡返回持有者卡组并洗切；若确实有卡返回卡组，则抽1张卡。
function c38395123.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组，并筛选出仍然与该效果相关的对象（没有离场或失效），确保处理时对象有效。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将筛选出的对象卡返回持有者卡组，并标记需要洗切卡组（SEQ_DECKSHUFFLE）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才送回卡组操作实际处理的卡组，用于后续判断是否成功洗牌和抽卡。
	local g=Duel.GetOperatedGroup()
	-- 如果实际返回卡组的卡中有位于卡组的卡，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断效果处理，使抽卡视为独立时点处理，避免错时点。
		Duel.BreakEffect()
		-- 玩家tp抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
