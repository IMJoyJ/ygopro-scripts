--イリュージョン・オブ・カオス
-- 效果：
-- 「混沌形态」降临
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。除仪式怪兽外的1只「黑魔术师」或者有那个卡名记述的怪兽从卡组加入手卡。那之后，选自己1张手卡回到卡组最上面。
-- ②：对方把怪兽的效果发动时才能发动。场上的这张卡回到手卡，从自己墓地把1只「黑魔术师」特殊召唤，那个发动的效果无效。
function c12266229.initial_effect(c)
	-- 记录该卡记载了「黑魔术师」（46986414）和「混沌形态」（21082832）的事实
	aux.AddCodeList(c,46986414,21082832)
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
-- 判断手卡中的这张卡是否可以给对方观看以进行发动
function c12266229.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：卡组中「黑魔术师」或记载有该卡名的非仪式怪兽且可以加入手牌
function c12266229.thfilter(c)
	-- 检查卡片本身是「黑魔术师」或其卡名记述中记述了「黑魔术师」，且可以加入手牌
	return aux.IsCodeOrListed(c,46986414) and c:IsAbleToHand()
		and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL)
end
-- 效果靶向：确认卡组存在符合检索条件的卡，并设置检索与返回卡组的操作信息
function c12266229.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12266229.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从手卡把1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从卡组把符合条件的卡加入手卡，然后选择手卡的1张卡回到卡组最上面
function c12266229.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12266229.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果选中的怪兽成功加入手卡
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 玩家选择手卡中1张要送回卡组的卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使加入手卡与送回卡组不视为同时发生
			Duel.BreakEffect()
			-- 将选中的卡送回自己卡组最上面
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 过滤条件：墓地中「黑魔术师」且可以特殊召唤
function c12266229.spfilter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件：对方把怪兽的效果发动时，且该效果可以被无效
function c12266229.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否是对方发动的怪兽效果，且该效果可被无效
	return rp~=tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果靶向：确认自身可回到手卡，墓地存在可以特召的「黑魔术师」，并设置操作信息
function c12266229.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡离开场上后自己场上是否有空怪兽区域，且这张卡是否可以回到手卡
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToHand()
		-- 检查自己墓地中是否存在「黑魔术师」可以特殊召唤
		and Duel.IsExistingMatchingCard(c12266229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：使该发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：从墓地把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：把场上的这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理：将这张卡回到手卡，特殊召唤墓地中的「黑魔术师」，并将对方发动的效果无效
function c12266229.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡依然适用于效果并成功送回玩家手手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 且玩家场上存在空怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择墓地中1只符合条件的「黑魔术师」（受王家长眠之谷限制）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12266229.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 如果选中的怪兽成功以表侧表示特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 使该发动的怪兽效果无效
			Duel.NegateEffect(ev)
		end
	end
end
