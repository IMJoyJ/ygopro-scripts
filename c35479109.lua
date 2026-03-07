--砂塵の大ハリケーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的魔法与陷阱区域盖放的卡任意数量为对象才能发动。盖放的那些卡和这张卡回到持有者手卡。那之后，自己可以把这个效果回到自己手卡的卡数量的魔法·陷阱卡从手卡盖放。
function c35479109.initial_effect(c)
	-- ①：以自己的魔法与陷阱区域盖放的卡任意数量为对象才能发动。盖放的那些卡和这张卡回到持有者手卡。那之后，自己可以把这个效果回到自己手卡的卡数量的魔法·陷阱卡从手卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,35479109+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35479109.target)
	e1:SetOperation(c35479109.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选自己魔法与陷阱区域盖放的卡（不包括场地魔法）且能送入手牌的卡片。
function c35479109.filter(c)
	return c:IsFacedown() and c:GetSequence()<5 and c:IsAbleToHand()
end
-- 效果处理时的处理函数，用于选择目标卡片。
function c35479109.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c35479109.filter(chkc) and chkc~=c end
	-- 判断是否满足发动条件：自己魔法与陷阱区域有至少一张盖放的卡且此卡能送入手牌。
	if chk==0 then return Duel.IsExistingTarget(c35479109.filter,tp,LOCATION_SZONE,0,1,c) and c:IsAbleToHand() end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡片：从自己魔法与陷阱区域选择1~5张盖放的卡。
	local g=Duel.SelectTarget(tp,c35479109.filter,tp,LOCATION_SZONE,0,1,5,c)
	g:AddCard(c)
	-- 设置操作信息：将选择的卡送入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 过滤函数，用于筛选与效果相关的盖放卡。
function c35479109.cfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFacedown()
end
-- 筛选函数，用于判断所选卡组是否满足盖放条件（场地魔法不超过1张，其余卡数量不超过可用区域数）。
function c35479109.fselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft
end
-- 效果发动时的处理函数，执行效果的主要逻辑。
function c35479109.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中已选定的目标卡组，并筛选出与当前效果相关的盖放卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c35479109.cfilter,nil,e)
	if c:IsRelateToEffect(e) and tg:GetCount()>0 then
		c:CancelToGrave()
		tg:AddCard(c)
		-- 将目标卡组送入手牌，若成功则继续处理后续逻辑。
		if Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 then
			-- 获取实际被送入手牌的卡组，并筛选出在手牌中的卡。
			local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_HAND)
			-- 获取自己魔法与陷阱区域的可用空位数。
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			-- 获取自己手牌中可以盖放的魔法与陷阱卡。
			local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
			-- 判断是否满足盖放条件：有送入手牌的卡，且手牌中有足够数量的卡可以盖放，玩家确认是否进行盖放。
			if #og>0 and g:CheckSubGroup(c35479109.fselect,#og,#og,ft) and Duel.SelectYesNo(tp,aux.Stringid(35479109,0)) then  --"是否把相同数量的卡从手卡盖放？"
				-- 中断当前效果，使之后的效果处理视为不同时处理。
				Duel.BreakEffect()
				-- 将玩家手牌洗切。
				Duel.ShuffleHand(tp)
				-- 提示玩家选择要盖放的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
				local sg=g:SelectSubGroup(tp,c35479109.fselect,false,#og,#og,ft)
				-- 将选择的卡从手牌盖放到魔法与陷阱区域。
				Duel.SSet(tp,sg,tp,false)
			end
		end
	end
end
