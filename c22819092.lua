--魚群探知機
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
function c22819092.initial_effect(c)
	-- 将海（22702055）登记为这张卡卡名上记述的卡，用于后续判断检索对象是否属于“有「海」的卡名记述”的怪兽。
	aux.AddCodeList(c,22702055)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把7星以下的1只有「海」的卡名记述的怪兽或者水属性通常怪兽加入手卡。场上有「海」存在的场合，可以再从卡组把1只水属性通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22819092+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22819092.target)
	e1:SetOperation(c22819092.activate)
	c:RegisterEffect(e1)
end
-- 定义检索用过滤器：选择卡组中7星以下、能加入手卡，且要么是“有「海」的卡名记述的怪兽”，要么是“水属性通常怪兽”的卡。
function c22819092.filter(c)
	return c:IsAbleToHand() and c:IsLevelBelow(7)
		-- 判定该卡必须满足“卡名有「海」的记述”或“水属性通常怪兽”这两个条件之一。
		and (aux.IsCodeListed(c,22702055) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)))
end
-- 效果发动时的目标检查与操作信息设定：确认卡组有合法检索对象，并登记“从卡组加入手卡”的操作信息。
function c22819092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：卡组中是否存在至少1张满足过滤条件的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c22819092.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为“从卡组将1张卡加入手卡”，供相关效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义特殊召唤用过滤器：选择卡组中水属性通常怪兽，并确认该怪兽可以被效果特殊召唤。
function c22819092.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：先检索并加入手卡、展示并洗切手卡；若场上有「海」且满足追加条件，则再特殊召唤1只水属性通常怪兽。
function c22819092.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c22819092.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切当前玩家的手卡，重置手卡顺序。
		Duel.ShuffleHand(tp)
		-- 判断场上是否存在「海」，并且自己主要怪兽区是否有空位可供特殊召唤。
		if Duel.IsEnvironment(22702055) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在至少1只可被特殊召唤的水属性通常怪兽。
			and Duel.IsExistingMatchingCard(c22819092.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否要再从卡组特殊召唤1只水属性通常怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(22819092,0)) then  --"是否从卡组把1只水属性通常怪兽特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤作为另一个效果处理，避免错误时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1只水属性通常怪兽作为特殊召唤对象。
			local sg=Duel.SelectMatchingCard(tp,c22819092.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
