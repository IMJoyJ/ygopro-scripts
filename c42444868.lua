--輪廻のパーシアス
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把手卡1张反击陷阱卡给对方观看，丢弃1张手卡，支付1000基本分才能发动。那个发动无效，那张卡回到持有者卡组。那之后，可以从卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤。
function c42444868.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时，把手卡1张反击陷阱卡给对方观看，丢弃1张手卡，支付1000基本分才能发动。那个发动无效，那张卡回到持有者卡组。那之后，可以从卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42444868.condition)
	e1:SetCost(c42444868.cost)
	e1:SetTarget(c42444868.target)
	e1:SetOperation(c42444868.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：连锁中发动的是怪兽效果或魔法·陷阱卡的发动，且该连锁的发动可以被无效
function c42444868.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断触发连锁是否为怪兽效果或魔法·陷阱卡的发动，并确认其发动可被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤手卡中处于非公开状态的反击陷阱卡
function c42444868.cfilter(c)
	return c:IsType(TYPE_COUNTER) and not c:IsPublic()
end
-- 发动代价检查：确认手卡有非公开反击陷阱、可丢弃手卡（或受「解放之阿里阿德涅」免除丢弃代价影响）且己方基本分不少于1000
function c42444868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认手卡中除自身外存在至少1张非公开的反击陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42444868.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 以及手卡中除自身外存在至少1张可丢弃的卡
		and (Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 或者己方玩家正处于免除反击陷阱丢弃手卡代价的效果（如「解放之阿里阿德涅」）影响下
		or Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE))
		-- 并确认己方基本分足够支付1000点代价
		and Duel.CheckLPCost(tp,1000) end
	-- 向己方发送选择要给对方观看的反击陷阱卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让己方从手卡选择1张非公开的反击陷阱卡
	local cg=Duel.SelectMatchingCard(tp,c42444868.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方展示所选的反击陷阱卡
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切己方手卡以结束公开状态
	Duel.ShuffleHand(tp)
	-- 若己方未受到免除丢弃手卡代价效果的影响，则执行手卡丢弃代价
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then
		-- 让己方从手卡选择1张可丢弃的卡作为发动代价丢弃
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
	-- 让己方支付1000点基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 发动前调用aux.ndcon确认目标卡可被送回卡组，并登记无效发动与送回卡组的操作信息
function c42444868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动无效后的对象卡是否满足送回持有者卡组的条件
	if chk==0 then return aux.ndcon(tp,re) end
	-- 登记无效该连锁发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 登记将发动无效的卡片送回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 过滤己方卡组或额外卡组中可特殊召唤且对应区域存在可用空位的「珀耳修斯」怪兽
function c42444868.spfilter(c,e,tp)
	return c:IsSetCard(0x10a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若怪兽在卡组，则检查己方主要怪兽区是否有可用空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 或若怪兽在额外卡组，则检查己方场地是否有供该额外卡组怪兽特殊召唤的可用空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果处理：无效对象发动并将其洗回持有者卡组，成功后可从己方卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤
function c42444868.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 使目标连锁的发动无效，并确认该卡片仍与该效果关联
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将发动无效的卡片以效果洗回持有者卡组，并确认其已回到卡组或额外卡组
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 从己方卡组和额外卡组检索满足条件的可特殊召唤「珀耳修斯」怪兽
			local g=Duel.GetMatchingGroup(c42444868.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
			-- 若存在可特殊召唤的「珀耳修斯」怪兽，询问己方是否进行特殊召唤
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(42444868,0)) then  --"是否特殊召唤？"
				-- 插入效果处理间断，使回卡组与后续特殊召唤视为不同时处理
				Duel.BreakEffect()
				-- 向己方发送选择要特殊召唤的「珀耳修斯」怪兽的提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 将选中的「珀耳修斯」怪兽以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
