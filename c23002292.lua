--レッド・リブート
-- 效果：
-- 这张卡也能把基本分支付一半从手卡发动。
-- ①：对方把陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。那之后，对方可以从卡组把1张陷阱卡在自身的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时对方不能把陷阱卡发动。
function c23002292.initial_effect(c)
	-- ①：对方把陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。那之后，对方可以从卡组把1张陷阱卡在自身的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c23002292.condition)
	e1:SetTarget(c23002292.target)
	e1:SetOperation(c23002292.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把基本分支付一半从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCost(c23002292.cost)
	e2:SetDescription(aux.Stringid(23002292,1))  --"适用「红色重启」的效果来发动"
	c:RegisterEffect(e2)
end
-- 连锁发动时，对方发动陷阱卡且该连锁可被无效时才能发动。
function c23002292.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 对方发动的是陷阱卡且该连锁可被无效。
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 支付一半基本分作为发动cost。
function c23002292.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤满足条件的陷阱卡。
function c23002292.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- 设置效果处理信息，确定将要无效对方的陷阱卡发动。
function c23002292.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，确定将要无效对方的陷阱卡发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 处理效果，使对方陷阱卡发动无效并盖放，然后对方可从卡组盖放一张陷阱卡，最后使对方在本回合不能发动陷阱卡。
function c23002292.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 使对方陷阱卡发动无效且该卡可被盖放。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsCanTurnSet() then
		rc:CancelToGrave()
		-- 将对方的陷阱卡变为里侧表示。
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 触发放置陷阱卡的时点。
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		-- 检索满足条件的陷阱卡。
		local g=Duel.GetMatchingGroup(c23002292.setfilter,tp,0,LOCATION_DECK,nil)
		-- 对方卡组有陷阱卡且对方魔法与陷阱区域有空位时，询问对方是否盖放陷阱卡。
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(23002292,0)) then  --"是否从卡组盖放陷阱卡？"
			-- 提示对方选择要盖放的陷阱卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的陷阱卡盖放。
			Duel.SSet(1-tp,sg:GetFirst())
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 使对方在本回合不能发动陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c23002292.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方不能发动陷阱卡的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 判断对方是否发动陷阱卡。
function c23002292.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
