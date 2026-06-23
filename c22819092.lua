--魚群探知機
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
function c22819092.initial_effect(c)
	-- 记录该卡具有「海」的卡名记述
	aux.AddCodeList(c,22702055)
	-- ①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22819092+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22819092.target)
	e1:SetOperation(c22819092.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选满足条件的怪兽：能加入手牌、等级不超过7、且为「海」的卡名记述或水属性通常怪兽
function c22819092.filter(c)
	return c:IsAbleToHand() and c:IsLevelBelow(7)
		-- 判断是否为「海」的卡名记述或水属性通常怪兽
		and (aux.IsCodeListed(c,22702055) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)))
end
-- 定义效果发动时的处理函数，检查是否能从卡组选择满足条件的卡
function c22819092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22819092.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义特殊召唤的过滤函数，用于筛选水属性通常怪兽
function c22819092.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的具体处理流程，包括选择并加入手牌、确认卡片、洗牌，并在满足条件时选择是否特殊召唤
function c22819092.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c22819092.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 检查是否在「海」的场地环境下且场上存在空位
		if Duel.IsEnvironment(22702055) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在满足特殊召唤条件的卡
			and Duel.IsExistingMatchingCard(c22819092.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否发动特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(22819092,0)) then  --"是否从卡组把1只水属性通常怪兽特殊召唤？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的卡进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,c22819092.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
