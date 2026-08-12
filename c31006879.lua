--ライディング・デュエル！アクセラレーション！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上没有其他卡存在的场合，可以从卡组把1只「同调士」怪兽加入手卡。
-- ②：自己准备阶段发动。给这张卡放置1个信号指示物。
-- ③：把自己场上2个信号指示物取除，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己抽2张。那之后，选自己1张手卡送去墓地。
function c31006879.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，自己场上没有其他卡存在的场合，可以从卡组把1只「同调士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31006879+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c31006879.activate)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。给这张卡放置1个信号指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31006879.ctcon)
	e2:SetTarget(c31006879.cttg)
	e2:SetOperation(c31006879.ctop)
	c:RegisterEffect(e2)
	-- ③：把自己场上2个信号指示物取除，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己抽2张。那之后，选自己1张手卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c31006879.drcost)
	e3:SetTarget(c31006879.drtg)
	e3:SetOperation(c31006879.drop)
	c:RegisterEffect(e3)
end
c31006879.mentioned_counter={
	[0x104d]=true,
}
-- 定义过滤器：满足是怪兽、属于「同调士」系列（0x1017）且可以加入手卡这三个条件的卡。
function c31006879.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1017) and c:IsAbleToHand()
end
-- 发动时的效果处理：若自己场上没有这张卡以外的卡，则询问是否从卡组把1只「同调士」怪兽加入手卡，选择后将该卡加入手卡并给对方确认。
function c31006879.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在这张卡以外的其他卡，存在则不适用检索效果，直接结束处理。
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then return end
	-- 从自己卡组中检索出所有满足过滤条件的「同调士」怪兽组成卡组。
	local g=Duel.GetMatchingGroup(c31006879.filter,tp,LOCATION_DECK,0,nil)
	-- 若检索结果不为空，则询问玩家是否从卡组把1只「同调士」怪兽加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31006879,0)) then  --"是否从卡组把1只「同调士」怪兽加入手卡？"
		-- 向玩家发送选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的1只「同调士」怪兽以效果处理加入持有者手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的发动条件函数：只在当前回合玩家是自己的时候满足（即自己的准备阶段）。
function c31006879.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，对应效果中「自己准备阶段发动」的条件。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的对象设定函数：宣言将给这张卡放置1个信号指示物，并设置指示物效果的操作信息。
function c31006879.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果分类为指示物效果，将放置1个信号指示物（0x104d）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x104d)
end
-- ②效果的处理函数：给这张卡放置1个信号指示物（0x104d）。
function c31006879.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x104d,1)
end
-- ③效果的代价函数：检查能否以代价取除自己场上2个信号指示物，且魔法与陷阱区域的这张卡能否作为代价送去墓地。
function c31006879.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认能以代价取除自己场上2个信号指示物（0x104d）。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x104d,2,REASON_COST)
		and e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，从自己场上取除2个信号指示物（0x104d）。
	Duel.RemoveCounter(tp,1,0,0x104d,2,REASON_COST)
	-- 作为发动代价，把魔法与陷阱区域的表侧表示的这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ③效果的对象设定函数：确认自己可以抽2张卡，设定对象玩家和抽卡数量，并设置抽卡与送墓的操作信息。
function c31006879.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己可以从卡组抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 把当前连锁的对象玩家设定为自己。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设定为2（即抽2张卡）。
	Duel.SetTargetParam(2)
	-- 设置操作信息：效果分类为抽卡，自己将抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：效果分类为送去墓地，将把自己手卡中的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND)
end
-- ③效果的处理函数：自己抽2张卡，抽卡成功后洗切手卡，再选自己1张手卡送去墓地。
function c31006879.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁信息中的对象玩家和对象参数（抽卡数量），存入变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家以效果处理抽卡，若实际抽了2张则继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 手动洗切自己的手卡。
		Duel.ShuffleHand(p)
		-- 中断当前效果处理，使之后的送墓处理与抽卡视为不同时进行。
		Duel.BreakEffect()
		-- 从自己手卡中选1张卡，以效果处理送去墓地。
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT)
	end
end
