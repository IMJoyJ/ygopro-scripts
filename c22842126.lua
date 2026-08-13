--汎神の帝王
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把1张「帝王」魔法·陷阱卡送去墓地才能发动。自己抽2张。
-- ②：把墓地的这张卡除外才能发动。从卡组把3张「帝王」魔法·陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
function c22842126.initial_effect(c)
	-- ①：从手卡把1张「帝王」魔法·陷阱卡送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22842126,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(c22842126.cost)
	e1:SetTarget(c22842126.target)
	e1:SetOperation(c22842126.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把3张「帝王」魔法·陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22842126,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22842126)
	-- 设置②效果的发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c22842126.thtg)
	e2:SetOperation(c22842126.thop)
	c:RegisterEffect(e2)
end
-- 定义代价滤筛：满足「帝王」魔法·陷阱卡且可以作为代价送去墓地的手卡。
function c22842126.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 代价函数：检查并执行从手卡丢弃1张「帝王」魔法·陷阱卡作为发动代价。
function c22842126.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：若为检查阶段，返回手卡是否存在至少1张满足cfilter的卡（且不是效果持有者本身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c22842126.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手卡选择1张满足cfilter的卡，以REASON_COST丢弃。
	Duel.DiscardHand(tp,c22842126.cfilter,1,1,REASON_COST,nil)
end
-- 目标函数：设定抽卡效果的对象为自己，抽2张；并写入抽卡操作信息。
function c22842126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：确认玩家tp可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设为tp（自己），表示抽卡对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为2，表示抽卡数量。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本连锁包含抽卡效果，对象玩家为tp，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息取得对象玩家和抽卡数量并执行抽卡。
function c22842126.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和参数，分别赋给p、d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p因效果抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义检索滤筛：卡组中「帝王」魔法·陷阱卡且可以被加入手卡的卡。
function c22842126.thfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 目标函数：确认卡组存在至少3张符合条件的卡，并设置回手牌检索操作信息。
function c22842126.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：卡组中是否存在至少3张满足thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22842126.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：本连锁包含回手牌/检索，预期将1张卡加入手卡，搜索范围是卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选3张符合条件的卡给对方确认，由对方选1张加入手牌，其余回卡组。
function c22842126.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足thfilter的卡，存入组g。
	local g=Duel.GetMatchingGroup(c22842126.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 给玩家tp显示选择提示（请选择要加入手牌的卡），用于自己选3张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡sg展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 给对方玩家显示选择提示（请选择要加入手牌的卡），由对方从3张中选1张。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选择的1张卡加入其持有者的手牌（即自己手牌），处理原因为效果。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
