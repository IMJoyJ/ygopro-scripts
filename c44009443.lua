--影星軌道兵器ハイドランダー
-- 效果：
-- 这张卡不能通常召唤。自己墓地有怪兽5只以上存在，那些怪兽的卡名全部不同的场合才能特殊召唤。
-- ①：1回合1次，从自己卡组上面把3张卡送去墓地才能发动。自己墓地的怪兽的卡名全部不同的场合，选场上1张卡破坏。这个效果在对方回合也能发动。
function c44009443.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法通常特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己墓地有怪兽5只以上存在，那些怪兽的卡名全部不同的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c44009443.spcon)
	c:RegisterEffect(e2)
	-- ①：1回合1次，从自己卡组上面把3张卡送去墓地才能发动。自己墓地的怪兽的卡名全部不同的场合，选场上1张卡破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44009443,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c44009443.descost)
	e3:SetTarget(c44009443.destg)
	e3:SetOperation(c44009443.desop)
	c:RegisterEffect(e3)
end
-- 检查是否满足特殊召唤条件：墓地怪兽数量不少于5且卡名各不相同。
function c44009443.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 获取玩家墓地中的所有怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>=5 and g:GetClassCount(Card.GetCode)==g:GetCount()
end
-- 支付效果代价：从自己卡组上面把3张卡送去墓地。
function c44009443.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以支付该代价。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	-- 执行将卡组最上面3张卡送去墓地的操作。
	Duel.DiscardDeck(tp,3,REASON_COST)
end
-- 设置效果的发动目标：选择场上一张卡进行破坏。
function c44009443.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家墓地中的所有怪兽卡。
	local cg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	if chk==0 then return cg:GetCount()>1 and cg:GetClassCount(Card.GetCode)==cg:GetCount() end
	-- 获取场上所有卡片。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定破坏效果的目标为场上一张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理：若满足条件则选择并破坏场上一张卡。
function c44009443.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家墓地中的所有怪兽卡。
	local cg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 获取场上所有卡片。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 and cg:GetCount()>1 and cg:GetClassCount(Card.GetCode)==cg:GetCount() then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示所选卡片被破坏的动画效果。
		Duel.HintSelection(sg)
		-- 将所选卡片破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
