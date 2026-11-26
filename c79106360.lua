--カオスポッド
-- 效果：
-- 反转：场上的怪兽全部加入持有者卡组洗切。那之后，双方玩家直到和加入各自卡组的数量相同数量的怪兽出现为止把卡组翻开，从那之中把4星以下的怪兽全部里侧守备表示特殊召唤。那以外的翻开的卡全部丢弃去墓地。
function c79106360.initial_effect(c)
	-- 反转：场上的怪兽全部加入持有者卡组洗切。那之后，双方玩家直到和加入各自卡组的数量相同数量的怪兽出现为止把卡组翻开，从那之中把4星以下的怪兽全部里侧守备表示特殊召唤。那以外的翻开的卡全部丢弃去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c79106360.target)
	e1:SetOperation(c79106360.operation)
	c:RegisterEffect(e1)
end
-- 反转必发效果的条件检查，确认该效果可以发动
function c79106360.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 过滤函数，检查是否为未处于战斗破坏确定状态且可以回到卡组的怪兽
function c79106360.filter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToDeck()
end
-- 效果处理，把场上非战破怪兽全部送回持有者卡组并统计双方各自返回卡组的怪兽数量
function c79106360.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有未处于战斗破坏确定状态且可回到卡组的怪兽
	local rg=Duel.GetMatchingGroup(c79106360.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将双方场上的怪兽全部送回各自持有者的卡组
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct1=0
	local ct2=0
	-- 获取实际回到卡组的卡片组，用于统计双方各自加入卡组的怪兽数量
	rg=Duel.GetOperatedGroup()
	local tc=rg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_DECK) and tc:IsType(TYPE_MONSTER) then
			if tc:IsControler(tp) then ct1=ct1+1
			else ct2=ct2+1 end
		end
		tc=rg:GetNext()
	end
	-- 若自己有怪兽回到卡组，洗切自己的卡组
	if ct1>0 then Duel.ShuffleDeck(tp) end
	-- 若对方有怪兽回到卡组，洗切对方的卡组
	if ct2>0 then Duel.ShuffleDeck(1-tp) end
	-- 中断当前效果处理，使后续翻卡与特殊召唤视为与前面的回卡组不同时处理
	Duel.BreakEffect()
	local g1=nil
	local g2=nil
	if ct1>0 then g1=c79106360.sp(e,tp,ct1) end
	if ct2>0 then g2=c79106360.sp(e,1-tp,ct2) end
	-- 完成双方所有4星以下怪兽的分步里侧守备表示特殊召唤
	Duel.SpecialSummonComplete()
	-- 洗切自己场上因该效果里侧守备表示特殊召唤的怪兽位置顺序
	if g1 then Duel.ShuffleSetCard(g1) end
	-- 洗切对方场上因该效果里侧守备表示特殊召唤的怪兽位置顺序
	if g2 then Duel.ShuffleSetCard(g2) end
end
-- 过滤函数，检查是否为4星以下且可里侧守备表示特殊召唤的怪兽
function c79106360.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 为指定玩家翻开卡组直到出现对应数量的怪兽，将其中4星以下怪兽里侧守备表示特殊召唤并把其余翻开的卡送去墓地
function c79106360.sp(e,tp,ct)
	-- 获取指定玩家当前卡组中的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local dt=g:GetCount()
	if dt==0 then return false end
	local dlist={}
	local tc=g:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) then dlist[tc:GetSequence()]=tc end
		tc=g:GetNext()
	end
	local i=dt-1
	local a=0
	local last=nil
	g=Group.CreateGroup()
	while a<ct and i>=0 do
		tc=dlist[i]
		if tc then
			g:AddCard(tc)
			last=tc
			a=a+1
		end
		i=i-1
	end
	local conf=dt-last:GetSequence()
	-- 翻开并向双方确认该玩家卡组最上方对应数量的卡
	Duel.ConfirmDecktop(tp,conf)
	-- 获取该玩家怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	g=g:Filter(c79106360.spfilter,nil,e,tp)
	if g:GetCount()>ft then
		-- 当符合条件的怪兽数超过场上空位时，提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	tc=g:GetFirst()
	while tc do
		-- 禁用紧接着特殊召唤操作的自动洗卡检测，以便后续正确把剩余翻开的卡送去墓地
		Duel.DisableShuffleCheck()
		-- 以分步方式将满足条件的4星以下怪兽里侧守备表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		tc=g:GetNext()
	end
	if conf-g:GetCount()>0 then
		-- 将其余未特殊召唤的翻开卡片全部送去墓地
		Duel.DiscardDeck(tp,conf-g:GetCount(),REASON_EFFECT+REASON_REVEAL)
	end
	return g
end
