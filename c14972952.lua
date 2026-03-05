--ヴァルモニカ・エレディターレ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
local s,id,o=GetID()
-- 注册两个效果：①连锁发动时无效并破坏对方发动的怪兽/魔法/陷阱效果；②墓地发动，将最多等于场上响鸣指示物数量的「异响鸣」卡送回卡组并抽卡。
function s.initial_effect(c)
	-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 将此卡从墓地除外作为发动②效果的费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的「异响鸣」连接怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 效果条件：场上存在「异响鸣」连接怪兽，且连锁的发动可以被无效。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「异响鸣」连接怪兽。
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁是否可以被无效。
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置效果处理时的操作信息：使发动无效并可能破坏目标卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏目标卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使连锁发动无效，并破坏对应卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡仍存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数：检查是否为表侧表示的「异响鸣」卡且可送回卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1a3) and c:IsAbleToDeck()
end
-- ②效果的发动条件与目标设置：计算场上响鸣指示物数量，获取可送回卡组的「异响鸣」卡。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上响鸣指示物数量。
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	-- 获取墓地、额外卡组、除外状态的「异响鸣」卡。
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
	if chk==0 then return ct>0 and tg:GetCount()>0 end
	-- 设置操作信息：将卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
-- ②效果的处理函数：选择并送回卡组，计算抽卡数量并询问是否抽卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上响鸣指示物数量。
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	if ct==0 then return end
	-- 提示玩家选择送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择最多等于响鸣指示物数量的「异响鸣」卡送回卡组。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,ct,nil)
	if tg:GetCount()>0 then
		-- 显示选卡动画。
		Duel.HintSelection(tg)
		-- 将选中的卡送回卡组。
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 获取实际操作的卡组。
			local og=Duel.GetOperatedGroup()
			local dr=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			local drc=math.floor(dr/3)
			-- 判断是否可以抽卡并询问玩家是否抽卡。
			if drc>0 and Duel.IsPlayerCanDraw(tp,drc) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断当前效果处理，使后续效果视为错时处理。
				Duel.BreakEffect()
				-- 让玩家抽卡。
				Duel.Draw(tp,drc,REASON_EFFECT)
			end
		end
	end
end
