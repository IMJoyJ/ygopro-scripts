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
-- 发动条件的判定：对方发动的效果为卡的发动且为陷阱卡的发动，并且该连锁可以被无效；同时还要求对方的发动者身份为对方（rp==1-tp）。
function c23002292.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 确认被连锁的效果是陷阱卡的发动效果，且该连锁可以被无效。
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 从手卡发动时追加的代价：检查阶段直接允许支付，实际结算时支付当前基本分的一半（向下取整）。
function c23002292.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家支付当前基本分一半的数值作为从手卡发动的代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义筛选条件：用于选择卡组中满足是陷阱卡且可以盖放到魔法与陷阱区的卡。
function c23002292.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- 发动时的目标处理：本效果不取对象；仅确认发动合法，并设定本连锁将执行“无效发动”的操作信息。
function c23002292.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这次连锁处理标记为无效发动，对象为对方发动的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：先将对方发动的陷阱卡的发动无效，并把那张卡直接里侧盖放；然后若对方卡组有可盖放的陷阱卡、魔陷区有空位且对方选择盖放，则让对方从卡组选1张陷阱卡盖放到其魔陷区；最后设置直到回合结束时对方不能发动陷阱卡的限制效果。
function c23002292.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 判断无效发动是否成功，且被无效的卡仍与该效果相关，并且该卡能够转为里侧表示；满足条件才执行直接盖放处理。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsCanTurnSet() then
		rc:CancelToGrave()
		-- 把被无效的陷阱卡直接变为里侧表示，相当于盖放到魔法与陷阱区域。
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 手动触发一次“放置魔陷”的时点事件，使该卡被盖放这一行为符合规则判定。
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		-- 获取对方卡组中所有满足“是陷阱卡且可以被盖放”条件的卡。
		local g=Duel.GetMatchingGroup(c23002292.setfilter,tp,0,LOCATION_DECK,nil)
		-- 如果存在可盖放的陷阱卡、对方魔陷区有空位，并且对方玩家选择“是”，则继续执行从卡组盖放陷阱卡的处理。
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(23002292,0)) then  --"是否从卡组盖放陷阱卡？"
			-- 发出选择提示，让玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的陷阱卡由对方自身盖放到其魔法与陷阱区域。
			Duel.SSet(1-tp,sg:GetFirst())
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c23002292.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方不能发动陷阱卡”的限制效果注册到场上，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定函数：若某效果是陷阱卡的卡的发动，则返回 true，即禁止该发动。
function c23002292.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
