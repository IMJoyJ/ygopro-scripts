--砂塵の大ハリケーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的魔法与陷阱区域盖放的卡任意数量为对象才能发动。盖放的那些卡和这张卡回到持有者手卡。那之后，自己可以把这个效果回到自己手卡的卡数量的魔法·陷阱卡从手卡盖放。
function c35479109.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的魔法与陷阱区域盖放的卡任意数量为对象才能发动。盖放的那些卡和这张卡回到持有者手卡。那之后，自己可以把这个效果回到自己手卡的卡数量的魔法·陷阱卡从手卡盖放。
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
-- 该函数是对象筛选条件：要求卡片为里侧表示、位于主要魔陷区（不是场地魔法格），并且可以被返回手卡。
function c35479109.filter(c)
	return c:IsFacedown() and c:GetSequence()<5 and c:IsAbleToHand()
end
-- 发动条件与选择对象阶段：验证所选对象是否合法，然后让玩家从己方魔陷区选择1~5张里侧表示的卡，并将此卡自身也加入对象，同时设置回手牌的操作信息。
function c35479109.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c35479109.filter(chkc) and chkc~=c end
	-- 检查发动合法性：己方魔陷区存在至少1张符合条件的里侧卡，且此卡自身可以被返回手卡时才可发动。
	if chk==0 then return Duel.IsExistingTarget(c35479109.filter,tp,LOCATION_SZONE,0,1,c) and c:IsAbleToHand() end
	-- 显示选择提示，提示玩家正在选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从符合条件的己方魔陷区里侧卡中选取1~5张作为效果对象，并将其登记为连锁对象。
	local g=Duel.SelectTarget(tp,c35479109.filter,tp,LOCATION_SZONE,0,1,5,c)
	g:AddCard(c)
	-- 设置操作信息：将对象组（包含此卡）标记为即将返回手牌，数量为对象组的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理时对象过滤条件：筛选仍然与此效果相关且为里侧表示的对象卡。
function c35479109.cfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFacedown()
end
-- 盖放选择限制函数：所选手卡中场地魔法卡最多1张，其他卡数不超过魔陷区空格数，以保证所有卡都能盖放。
function c35479109.fselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft
end
-- 效果处理阶段：取得仍有效的对象，若此卡仍在场则取消其送墓状态并加入对象组，将对象组返回手卡；若实际回手成功，则让玩家选择相同数量的可盖放魔陷从手卡盖放。
function c35479109.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取得发动时选择的对象，并过滤掉已离场或不再与效果相关的卡，得到当前有效对象组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c35479109.cfilter,nil,e)
	if c:IsRelateToEffect(e) and tg:GetCount()>0 then
		c:CancelToGrave()
		tg:AddCard(c)
		-- 将有效对象组送回持有者手卡，若至少有一张成功回手则继续执行后续盖放处理。
		if Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 then
			-- 取得上一步操作中实际被送回手卡的卡，并筛选出当前确实位于手卡的卡，用于计算回手数量。
			local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_HAND)
			-- 计算己方魔陷区当前剩余可用空格数，作为后来盖放数量的上限。
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			-- 从手卡中筛选出所有可以盖放到魔陷区的魔法·陷阱卡，供玩家选择。
			local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
			-- 若回手数大于0且手卡中存在一组数量等于回手数、且能全部盖放的卡，则询问玩家是否要按相同数量从手卡盖放。
			if #og>0 and g:CheckSubGroup(c35479109.fselect,#og,#og,ft) and Duel.SelectYesNo(tp,aux.Stringid(35479109,0)) then  --"是否把相同数量的卡从手卡盖放？"
				-- 中断当前效果处理，使盖放动作作为一个独立处理执行，避免与其他处理同时进行。
				Duel.BreakEffect()
				-- 洗切己方手卡，隐藏手卡顺序信息。
				Duel.ShuffleHand(tp)
				-- 显示选择提示，提示玩家正在选择要盖放的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
				local sg=g:SelectSubGroup(tp,c35479109.fselect,false,#og,#og,ft)
				-- 将玩家选出的手卡中的魔法·陷阱卡以里侧表示盖放到己方魔陷区。
				Duel.SSet(tp,sg,tp,false)
			end
		end
	end
end
