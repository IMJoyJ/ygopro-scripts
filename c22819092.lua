--魚群探知機
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
function c22819092.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「海」(22702055)的卡名
	aux.AddCodeList(c,22702055)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22819092+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22819092.target)
	e1:SetOperation(c22819092.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选卡组中可加入手卡、7星以下且有「海」卡名记述或为水属性通常怪兽的卡片
function c22819092.filter(c)
	return c:IsAbleToHand() and c:IsLevelBelow(7)
		-- 检查卡片文本是否记载了「海」(22702055)的卡名，或者是否为水属性通常怪兽
		and (aux.IsCodeListed(c,22702055) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)))
end
-- 效果Target函数：检测己方卡组中是否存在满足检索条件的怪兽，并设置从卡组把1张卡加入手卡的操作信息
function c22819092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张符合检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22819092.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：筛选卡组中可被特殊召唤的水属性通常怪兽
function c22819092.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：从卡组选1张符合条件的卡加入手卡；若场上有「海」，询问玩家是否再从卡组特殊召唤1只水属性通常怪兽
function c22819092.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1只满足检索条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c22819092.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选中的怪兽加入其持有者（己方）手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 手动洗切己方手卡
		Duel.ShuffleHand(tp)
		-- 检查场上是否存在生效中的「海」(22702055)且己方主要怪兽区仍有空位
		if Duel.IsEnvironment(22702055) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查己方卡组中是否存在至少1只可特殊召唤的水属性通常怪兽
			and Duel.IsExistingMatchingCard(c22819092.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问己方玩家是否要再从卡组特殊召唤1只水属性通常怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(22819092,0)) then  --"是否从卡组把1只水属性通常怪兽特殊召唤？"
			-- 中断当前处理步骤，使后续的特殊召唤与检索加入手卡视为不同时处理
			Duel.BreakEffect()
			-- 向己方玩家发送选择要特殊召唤的怪兽提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从己方卡组中选择1只可特殊召唤的水属性通常怪兽
			local sg=Duel.SelectMatchingCard(tp,c22819092.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 将选中的水属性通常怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
