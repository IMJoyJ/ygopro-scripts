--カオスポッド
-- 效果：
-- 反转：场上的怪兽全部加入持有者卡组洗切。那之后，双方玩家直到和加入各自卡组的数量相同数量的怪兽出现为止把卡组翻开，从那之中把4星以下的怪兽全部里侧守备表示特殊召唤。那以外的翻开的卡全部丢弃去墓地。
function c79106360.initial_effect(c)
	-- 反转：场上的怪兽全部加入持有者卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c79106360.target)
	e1:SetOperation(c79106360.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与合法性检测（反转效果默认返回true）
function c79106360.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 过滤场上未被战斗破坏且可以回到卡组的怪兽
function c79106360.filter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToDeck()
end
-- 效果处理：将场上的怪兽全部回到持有者卡组洗切，并统计双方玩家实际回到卡组的怪兽数量
function c79106360.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有未被战斗破坏且可以回到卡组的怪兽
	local rg=Duel.GetMatchingGroup(c79106360.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽全部送回持有者卡组并洗牌
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct1=0
	local ct2=0
	-- 获取实际被送回卡组的卡片组
	rg=Duel.GetOperatedGroup()
	local tc=rg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_DECK) and tc:IsType(TYPE_MONSTER) then
			if tc:IsControler(tp) then ct1=ct1+1
			else ct2=ct2+1 end
		end
		tc=rg:GetNext()
	end
	-- 若自身有怪兽回到卡组，则洗切自身卡组
	if ct1>0 then Duel.ShuffleDeck(tp) end
	-- 若对方有怪兽回到卡组，则洗切对方卡组
	if ct2>0 then Duel.ShuffleDeck(1-tp) end
	-- 中断当前效果处理，用于连接“那之后”的后续处理（造成错时点）
	Duel.BreakEffect()
	local g1=nil
	local g2=nil
	if ct1>0 then g1=c79106360.sp(e,tp,ct1) end
	if ct2>0 then g2=c79106360.sp(e,1-tp,ct2) end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
	-- 若自身有特殊召唤的里侧怪兽，则洗切这些里侧怪兽
	if g1 then Duel.ShuffleSetCard(g1) end
	-- 若对方有特殊召唤的里侧怪兽，则洗切这些里侧怪兽
	if g2 then Duel.ShuffleSetCard(g2) end
end
-- 过滤4星以下且可以里侧守备表示特殊召唤的怪兽
function c79106360.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 执行翻开卡组、特殊召唤4星以下怪兽、将其余卡送去墓地的处理
function c79106360.sp(e,tp,ct)
	-- 获取玩家卡组中的所有卡
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
	-- 确认（翻开）玩家卡组最上方指定数量的卡
	Duel.ConfirmDecktop(tp,conf)
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	g=g:Filter(c79106360.spfilter,nil,e,tp)
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	tc=g:GetFirst()
	while tc do
		-- 禁用接下来的洗卡检测，防止在特殊召唤过程中自动洗卡
		Duel.DisableShuffleCheck()
		-- 将怪兽以里侧守备表示特殊召唤到场上（单步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		tc=g:GetNext()
	end
	if conf-g:GetCount()>0 then
		-- 将翻开的卡中除了特殊召唤的怪兽以外的卡全部送去墓地
		Duel.DiscardDeck(tp,conf-g:GetCount(),REASON_EFFECT+REASON_REVEAL)
	end
	return g
end
