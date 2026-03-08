--輪廻のパーシアス
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把手卡1张反击陷阱卡给对方观看，丢弃1张手卡，支付1000基本分才能发动。那个发动无效，那张卡回到持有者卡组。那之后，可以从卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤。
function c42444868.initial_effect(c)
	-- 创建效果，设置效果分类为无效发动、送回卡组、特殊召唤和卡组处理，类型为发动效果，连锁时触发，条件为怪兽效果或魔法陷阱发动且可无效，费用为选择反击陷阱卡、丢弃手卡、支付1000基本分，目标为无效发动并送回卡组，效果为无效发动并送回卡组后特殊召唤珀耳修斯怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42444868.condition)
	e1:SetCost(c42444868.cost)
	e1:SetTarget(c42444868.target)
	e1:SetOperation(c42444868.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断，当发动的是怪兽效果或魔法陷阱卡且该连锁可被无效时效果才能发动
function c42444868.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动时的条件：发动的是怪兽效果或魔法陷阱卡，且该连锁可被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 反击陷阱卡的过滤函数，筛选手牌中类型为反击陷阱且未公开的卡
function c42444868.cfilter(c)
	return c:IsType(TYPE_COUNTER) and not c:IsPublic()
end
-- 效果发动的费用判断，需要手牌中有反击陷阱卡，且有可丢弃的手卡或受解放之阿里阿德涅影响，且能支付1000基本分
function c42444868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在反击陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42444868.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查手牌中是否存在可丢弃的卡
		and (Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查玩家是否受解放之阿里阿德涅影响
		or Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE))
		-- 检查玩家是否能支付1000基本分
		and Duel.CheckLPCost(tp,1000) end
	-- 提示玩家选择要给对方确认的反击陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张反击陷阱卡给对方确认
	local cg=Duel.SelectMatchingCard(tp,c42444868.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的反击陷阱卡
	Duel.ConfirmCards(1-tp,cg)
	-- 将玩家手牌洗切
	Duel.ShuffleHand(tp)
	-- 判断玩家是否未受解放之阿里阿德涅影响
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then
		-- 丢弃一张手卡作为费用
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
	-- 支付1000基本分作为费用
	Duel.PayLPCost(tp,1000)
end
-- 设置效果目标，检查是否满足无效发动条件，若发动卡与效果相关则设置送回卡组操作信息
function c42444868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足无效发动的条件
	if chk==0 then return aux.ndcon(tp,re) end
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置送回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 特殊召唤的过滤函数，筛选珀耳修斯怪兽，且满足特殊召唤条件和召唤区域可用
function c42444868.spfilter(c,e,tp)
	return c:IsSetCard(0x10a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断卡在卡组且场上怪兽区可用
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 判断卡在额外卡组且额外召唤区域可用
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果发动的处理函数，无效发动并送回卡组，若成功则从卡组或额外卡组特殊召唤珀耳修斯怪兽
function c42444868.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 无效发动并确认发动卡与效果相关
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将发动卡送回卡组并确认卡在卡组或额外卡组
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 获取卡组和额外卡组中满足条件的珀耳修斯怪兽
			local g=Duel.GetMatchingGroup(c42444868.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
			-- 判断是否有满足条件的怪兽且玩家选择特殊召唤
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(42444868,0)) then  --"是否特殊召唤？"
				-- 中断当前效果，使后续处理视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 将选中的卡特殊召唤到场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
