--ヴァルモニカ・エレディターレ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
local s,id,o=GetID()
-- 初始化效果对象。e1对应①号效果（连锁发动无效并破坏），e2对应②号效果（除外回收及抽卡）。两者共享同名卡的“一回合一次”限制计数槽位 id。
function s.initial_effect(c)
	-- 对应效果原文①：“自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文②：“把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- e2效果的发动代价：将墓地中的这张卡除外（aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- e1效果的发动条件检查函数定义：用于确认场上是否存在表侧存在的「异响鸣」连接怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- e1效果的发动条件判定函数：检查场上是否有符合条件的「异响鸣」连接怪兽、连锁是否可被无效，以及目标卡是否为怪兽效果或魔陷发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- e1条件检查第一步：确认场上是否有至少一张表侧存在的「异响鸣」连接怪兽。
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- e1条件检查第二步：确认当前连锁是否允许发动无效效果（排除如“王家长眠之谷”等不可被无效的场合）。
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- e1效果的处理目标设定函数定义：确定要无效并破坏的连锁对象（通常为发动效果的卡）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记本次处理包含“使发动无效”类别。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若目标卡可被破坏且与效果相关，设置操作信息包含“破坏”类别。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- e1效果的发动处理函数定义：实际执行连锁无效和破坏操作。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使当前连锁的发动无效，并检查目标卡是否与效果相关（决定是否破坏）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效的连锁对象。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- e2效果的目标筛选函数定义：确定哪些「异响鸣」卡（除本体外）可以从额外卡组、墓地或除外区返回卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1a3) and c:IsAbleToDeck()
end
-- e2效果的处理目标设定函数定义：计算场上「异响鸣」指示物数量，获取符合条件的卡组候选对象。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- e2目标检查第一步：统计场上「异响鸣」怪兽的指示物数量（代码 0x6a 对应响鸣指示物）。
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	-- e2目标检查第二步：获取所有符合条件的「异响鸣」卡组成的卡组候选组。
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
	if chk==0 then return ct>0 and tg:GetCount()>0 end
	-- 设置操作信息，标记本次处理包含“回卡组”类别（数量上限为指示物数量）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
-- e2效果的发动处理函数定义：执行选卡、回卡组及可能的抽卡流程。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- e2操作阶段再次确认场上「异响鸣」指示物数量，用于限制选卡上限。
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	if ct==0 then return end
	-- e2操作阶段提示玩家选择要送回卡组的目标卡片（HINT_SELECTMSG）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- e2操作阶段让玩家选择最多 ct 张符合条件的「异响鸣」卡（不受王家长眠之谷影响）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,ct,nil)
	if tg:GetCount()>0 then
		-- 记录玩家选择的卡片组，以便后续处理。
		Duel.HintSelection(tg)
		-- e2操作阶段将选定的卡送回卡组（洗切），并检查实际回卡的张数。
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 获取刚刚被送入卡组的卡片组对象，用于计算数量。
			local og=Duel.GetOperatedGroup()
			local dr=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			local drc=math.floor(dr/3)
			-- e2操作阶段计算可抽卡数量（回卡组张数/3），检查玩家能否抽卡，并询问玩家是否需要执行抽卡。
			if drc>0 and Duel.IsPlayerCanDraw(tp,drc) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断当前效果处理流程，使后续的抽卡操作视为不同时点（错时点）。
				Duel.BreakEffect()
				-- e2操作阶段让玩家以效果原因抽取计算出的卡片数量。
				Duel.Draw(tp,drc,REASON_EFFECT)
			end
		end
	end
end
