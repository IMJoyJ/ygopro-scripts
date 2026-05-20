--運命のドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己基本分比对方少，场上的攻击力最高的怪兽在对方场上存在的场合才能发动。从卡组选3张卡名不同的卡给对方观看，那3张洗切回到卡组上面。那之后，自己从卡组抽1张。这张卡的发动后，直到回合结束时自己不能把魔法·陷阱卡盖放，只能有1次把魔法·陷阱·怪兽的效果发动。
function c856784.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己基本分比对方少，场上的攻击力最高的怪兽在对方场上存在的场合才能发动。从卡组选3张卡名不同的卡给对方观看，那3张洗切回到卡组上面。那之后，自己从卡组抽1张。这张卡的发动后，直到回合结束时自己不能把魔法·陷阱卡盖放，只能有1次把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,856784+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c856784.condition)
	e1:SetTarget(c856784.target)
	e1:SetOperation(c856784.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己LP比对方少，且场上表侧表示的攻击力最高的怪兽在对方场上存在
function c856784.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 判断场上攻击力最高的怪兽是否由对方控制，且自己的LP是否低于对方
	return tg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 效果发动的目标检查与操作信息设置：检查自身是否能抽卡，以及卡组中是否存在至少3种不同卡名的卡，并设置抽卡的操作信息
function c856784.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以进行抽卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		-- 获取自己卡组中的所有卡片
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
	-- 设置效果处理时的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的核心逻辑：从卡组选3张卡名不同的卡给对方观看并洗切回卡组最上方，然后抽1张卡，并注册不能盖放魔陷和只能发动1次效果的限制
function c856784.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组中的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从卡组中选择3张卡名互不相同的卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选出的3张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自身卡组，若洗牌成功则继续处理
		if Duel.ShuffleDeck(tp)~=0 then
			for i=1,3 do
				local tc
				if i<3 then
					tc=sg:RandomSelect(tp,1):GetFirst()
				else
					tc=sg:GetFirst()
				end
				-- 将选中的卡片移动到卡组最上方
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				sg:RemoveCard(tc)
			end
		end
		-- 因效果让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不能把魔法·陷阱卡盖放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 为发动玩家注册“不能盖放魔法·陷阱卡”的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 添加自定义活动计数器，用于记录本回合玩家发动魔法、陷阱、怪兽效果的次数
	Duel.AddCustomActivityCounter(856784,ACTIVITY_CHAIN,c856784.chainfilter)
	-- 只能有1次把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c856784.actcon)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动玩家注册“不能发动魔法·陷阱·怪兽效果”的全局效果
	Duel.RegisterEffect(e3,tp)
end
-- 自定义计数器的过滤函数，返回false表示所有效果的发动都会被计数器记录
function c856784.chainfilter(re,tp,cid)
	return false
end
-- 限制效果发动的条件函数，当本回合玩家发动效果的次数不为0时，触发禁止发动的限制
function c856784.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查玩家在本回合中是否已经进行过至少1次效果的发动
	return Duel.GetCustomActivityCount(856784,tp,ACTIVITY_CHAIN)~=0
end
