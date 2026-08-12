--ヴァルモニカ・エレディターレ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
local s,id,o=GetID()
-- 初始化本卡的两个效果：注册①效果（连锁发动时使发动无效并破坏，魔陷发动型，与②效果合计1回合1次）和②效果（墓地发动的诱发即时回收效果，以除外这张卡为代价）
function s.initial_effect(c)
	-- ①：自己场上有「异响鸣」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
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
	-- ②：把墓地的这张卡除外才能发动。让最多有自己场上的响鸣指示物数量的「异响鸣的继承」以外的自己的额外卡组（表侧）·墓地·除外状态的「异响鸣」卡回到卡组。那之后，自己可以抽出回去的卡每3张为1张的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 定义过滤条件：表侧表示的「异响鸣」连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- ①效果的发动条件：自己场上存在「异响鸣」连接怪兽，当前连锁的发动可以被无效，且连锁发动的是怪兽的效果或魔法·陷阱卡的发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「异响鸣」连接怪兽，不存在则不能发动
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁的发动能否被无效，不能无效则不能发动
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ①效果的目标设定：设置操作信息，声明将对该连锁发动的卡进行无效处理，若该卡可以被破坏则同时声明破坏处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明将使该连锁发动的卡的效果发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：声明将破坏该连锁发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的处理：使那个发动无效，若成功且该卡仍与效果关联则将其破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效，并确认发动的卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏该连锁发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义过滤条件：表侧存在（含额外卡组表侧·除外状态）的「异响鸣的继承」以外的「异响鸣」卡，且可以回到卡组
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1a3) and c:IsAbleToDeck()
end
-- ②效果的目标设定：统计自己场上响鸣指示物的总数，检索额外卡组（表侧）·墓地·除外状态可回到卡组的「异响鸣」卡，要求指示物数量和可回卡数量均大于0才能发动，并设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上所有卡上响鸣指示物（0x6a）的总数
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	-- 检索自己的额外卡组（表侧）·墓地·除外状态中满足条件的「异响鸣」卡
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
	if chk==0 then return ct>0 and tg:GetCount()>0 end
	-- 设置操作信息：声明将把至少1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
-- ②效果的处理：重新统计响鸣指示物数量，让玩家选择最多该数量的「异响鸣」卡回到卡组并洗牌，然后统计实际回到卡组·额外卡组的数量，每3张为1张计算可抽卡数，玩家确认后抽相应数量的卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上所有卡上响鸣指示物（0x6a）的总数，为0则中断处理
	local ct=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):GetSum(Card.GetCounter,0x6a)
	if ct==0 then return end
	-- 向玩家显示选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从额外卡组（表侧）·墓地·除外状态选择1至响鸣指示物数量张满足条件且不受王家长眠之谷影响的「异响鸣」卡
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,ct,nil)
	if tg:GetCount()>0 then
		-- 为选择的卡显示被选为对象的动画并记录
		Duel.HintSelection(tg)
		-- 将选择的卡回到卡组并洗牌，成功则继续处理
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 取得刚才实际回到卡组的卡片组
			local og=Duel.GetOperatedGroup()
			local dr=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			local drc=math.floor(dr/3)
			-- 计算回去的卡每3张为1张的抽卡数量，若大于0且玩家可以抽卡，询问玩家是否抽卡
			if drc>0 and Duel.IsPlayerCanDraw(tp,drc) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断当前效果，使之后的抽卡处理与回卡组处理视为不同时处理
				Duel.BreakEffect()
				-- 让玩家以效果原因抽出计算好的数量的卡
				Duel.Draw(tp,drc,REASON_EFFECT)
			end
		end
	end
end
