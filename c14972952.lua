--ヴァルモニカ・エレディターレ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
local s,id,o=GetID()
-- 注册两个效果，第一个为发动无效并破坏效果，第二个为除外自身将异响鸣卡送回卡组并抽卡的效果
function s.initial_effect(c)
	-- 效果①，自己场上有异响鸣连接怪兽存在时，怪兽的效果·魔法·陷阱卡发动时才能发动，那个发动无效并破坏
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
	-- 效果②，把墓地的这张卡除外才能发动，让最多有自己场上的响鸣指示物数量的异响鸣卡回到卡组，之后可以抽卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 过滤场上存在的异响鸣连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 判断是否满足效果①的发动条件，即己方场上有异响鸣连接怪兽且连锁可无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在异响鸣连接怪兽
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置效果①的处理信息，包括使发动无效和破坏目标卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果①的实际处理，即使连锁无效并破坏对应卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤可送回卡组的异响鸣卡
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1a3) and c:IsAbleToDeck()
end
-- 设置效果②的处理信息，计算最多能送回多少张卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上的响鸣指示物数量
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	-- 获取满足条件的异响鸣卡组
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
	if chk==0 then return ct>0 and tg:GetCount()>0 end
	-- 设置将卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
-- 执行效果②的实际处理，包括选择送回卡组的卡、送回并抽卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的响鸣指示物数量
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	if ct==0 then return end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的异响鸣卡，最多为场上响鸣指示物数量
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,ct,nil)
	if tg:GetCount()>0 then
		-- 显示选中的卡作为对象
		Duel.HintSelection(tg)
		-- 将选中的卡送回卡组并洗牌
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 获取实际操作的卡组
			local og=Duel.GetOperatedGroup()
			local dr=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			local drc=math.floor(dr/3)
			-- 判断是否可以抽卡并询问玩家是否抽卡
			if drc>0 and Duel.IsPlayerCanDraw(tp,drc) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断当前效果处理，使后续效果视为不同时处理
				Duel.BreakEffect()
				-- 让玩家抽取指定数量的卡
				Duel.Draw(tp,drc,REASON_EFFECT)
			end
		end
	end
end
