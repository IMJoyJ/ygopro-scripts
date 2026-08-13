--輪廻のパーシアス
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把手卡1张反击陷阱卡给对方观看，丢弃1张手卡，支付1000基本分才能发动。那个发动无效，那张卡回到持有者卡组。那之后，可以从卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤。
function c42444868.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时，把手卡1张反击陷阱卡给对方观看，丢弃1张手卡，支付1000基本分才能发动。那个发动无效，那张卡回到持有者卡组。那之后，可以从卡组·额外卡组选1只「珀耳修斯」怪兽特殊召唤。
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
-- 本效果的发动条件：被连锁的卡为怪兽效果或魔法·陷阱卡发动，并且该发动能够被无效。
function c42444868.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果是否为怪兽效果或魔法·陷阱卡的发动，且该连锁可被无效。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 筛选手卡中1张非公开状态的反击陷阱卡，用于满足展示代价。
function c42444868.cfilter(c)
	return c:IsType(TYPE_COUNTER) and not c:IsPublic()
end
-- 发动代价的检查与处理：需要手卡中存在非公开的反击陷阱卡、能丢弃手卡（或有丢弃代价变更效果）且能支付1000基本分。
function c42444868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在1张符合条件的非公开反击陷阱卡（不包含效果发动者自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c42444868.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查手卡中是否存在1张可以丢弃的卡，用于满足丢弃手卡的代价。
		and (Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 或者我方受到“丢弃手卡代价变更”效果影响时，也视为满足丢弃手卡的代价条件。
		or Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE))
		-- 同时检查我方能否支付1000基本分作为发动代价。
		and Duel.CheckLPCost(tp,1000) end
	-- 弹出选择提示，要求玩家选择1张手卡给对方确认（这里选择反击陷阱卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张符合条件的反击陷阱卡，作为展示给对方确认的代价。
	local cg=Duel.SelectMatchingCard(tp,c42444868.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	-- 展示后洗切我方的剩余手卡，避免泄露手卡顺序信息。
	Duel.ShuffleHand(tp)
	-- 如果玩家没有受到“丢弃手卡代价变更”效果影响，则需要执行丢弃手卡。
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then
		-- 从手卡丢弃1张可以丢弃的卡，作为发动代价（同时视为代价丢弃）。
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
	-- 支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 发动时的目标合法性与操作信息设置：检查被连锁的卡在无效后能否回卡组，并设置无效和回卡组的操作信息。
function c42444868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：被连锁的卡片在发动被无效后能否送回持有者卡组（使用辅助函数 ndcon 检查）。
	if chk==0 then return aux.ndcon(tp,re) end
	-- 设置操作信息：本次效果包含使对方发动无效（CATEGORY_NEGATE），对象为正在连锁的卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：被连锁的卡仍与效果关联时，将其回持有者卡组（CATEGORY_TODECK）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 特殊召唤候选的筛选函数：从卡组或额外卡组选择卡名对应“珀耳修斯”（setname 0x10a）且可以特殊召唤的怪兽，并检查对应区域是否有空格。
function c42444868.spfilter(c,e,tp)
	return c:IsSetCard(0x10a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡在卡组中，则要求我方怪兽区域存在可用的空格。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若候选卡在额外卡组中，则要求从额外卡组特殊召唤时有可用的额外怪兽区域（或可用空格）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果处理：无效对方发动并将该卡弹回持有者卡组；之后，从卡组·额外卡组选1只“珀耳修斯”怪兽特殊召唤。
function c42444868.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 如果成功无效该连锁，且被无效的卡仍与效果关联，则继续执行回卡组处理。
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将那张卡弹回持有者卡组并洗切；只有弹回成功且该卡位于卡组或额外卡组时，才执行后续特殊召唤。
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 获取所有符合条件的“珀耳修斯”候选怪兽（从卡组和额外卡组中检索）。
			local g=Duel.GetMatchingGroup(c42444868.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
			-- 如果存在候选怪兽，则询问玩家是否发动特殊召唤效果；玩家选择“是”才继续。
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(42444868,0)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使后续的特殊召唤处理与之前的无效/回卡组效果分开，避免错过时点。
				Duel.BreakEffect()
				-- 弹出特殊召唤选择提示，让玩家选择要特殊召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
