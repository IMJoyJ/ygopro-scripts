--イリュージョン・オブ・カオス
-- 效果：
-- 「混沌形态」降临
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。除仪式怪兽外的1只「黑魔术师」或者有那个卡名记述的怪兽从卡组加入手卡。那之后，选自己1张手卡回到卡组最上面。
-- ②：对方把怪兽的效果发动时才能发动。场上的这张卡回到手卡，从自己墓地把1只「黑魔术师」特殊召唤，那个发动的效果无效。
function c12266229.initial_effect(c)
	-- 为卡片注册与「黑魔术师」相关的卡号列表，用于后续效果判断是否为相关卡片
	aux.AddCodeList(c,46986414)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。除仪式怪兽外的1只「黑魔术师」或者有那个卡名记述的怪兽从卡组加入手卡。那之后，选自己1张手卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12266229,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12266229)
	e1:SetCost(c12266229.thcost)
	e1:SetTarget(c12266229.thtg)
	e1:SetOperation(c12266229.thop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时才能发动。场上的这张卡回到手卡，从自己墓地把1只「黑魔术师」特殊召唤，那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12266229,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,12266230)
	e2:SetCondition(c12266229.discon)
	e2:SetTarget(c12266229.distg)
	e2:SetOperation(c12266229.disop)
	c:RegisterEffect(e2)
end
-- 设置效果发动时的费用检查函数，用于判断是否已公开手卡
function c12266229.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 定义检索过滤器，用于筛选满足条件的怪兽卡片
function c12266229.thfilter(c)
	-- 过滤器条件：卡片为「黑魔术师」或其记述卡片，并且可以送入手卡
	return aux.IsCodeOrListed(c,46986414) and c:IsAbleToHand()
		and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL)
end
-- 设置效果发动时的目标选择函数，用于判断是否可以发动效果
function c12266229.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c12266229.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将一张卡从卡组送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将一张手卡送回卡组顶部
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 设置效果发动时的操作函数，用于执行效果处理
function c12266229.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c12266229.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将卡片送入手卡，则执行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要送回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		-- 从手卡中选择一张可送回卡组的卡片
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将选定的卡片送回卡组顶部
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 定义特殊召唤过滤器，用于筛选可特殊召唤的「黑魔术师」
function c12266229.spfilter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的条件函数，用于判断是否可以发动效果
function c12266229.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件：对方发动效果且该效果可被无效，并且是怪兽效果
	return rp~=tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 设置效果发动时的目标选择函数，用于判断是否可以发动效果
function c12266229.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件：场上存在空位且该卡可送入手卡
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToHand()
		-- 并且墓地存在可特殊召唤的「黑魔术师」
		and Duel.IsExistingMatchingCard(c12266229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：将该卡送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 设置效果发动时的操作函数，用于执行效果处理
function c12266229.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与效果相关且可送入手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 并且场上存在空位可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从墓地中选择满足条件的「黑魔术师」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12266229.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 若成功特殊召唤，则执行后续处理
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 使对方发动的效果无效
			Duel.NegateEffect(ev)
		end
	end
end
