--メルフィーがころんだ
-- 效果：
-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将这张卡作为cost移除，用于效果的启动条件。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，记录特殊召唤次数，限制同名卡的重复使用。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 定义counterfilter函数，用于判断是否为童话动物怪兽且表侧表示。
function s.counterfilter(c)
	return c:IsSetCard(0x146) and c:IsFaceup()
end
-- 定义cost函数，检查本回合是否已经特殊召唤过童话动物怪兽。如果未进行过特殊召唤，则注册一个场效果，禁止玩家特殊召唤非「童话动物」怪兽。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的特殊召唤计数器是否为0，即判断是否可以发动该效果。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册场效果，禁止特殊召唤非童话动物怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 定义splimit函数，用于限制特殊召唤的怪兽种类。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x146)
end
-- 定义thfilter函数，用于筛选可以加入手牌的「童话动物」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义target函数，检查卡组中是否存在满足条件的「童话动物」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足s.thfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将一张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义activate函数，实现检索效果和跳过阶段的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组获取符合条件的怪兽组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的怪兽组中选择最多4张。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,4)
	-- 如果成功检索到卡片，则执行后续操作。
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 确认送去对方场上的卡片。
		Duel.ConfirmCards(1-tp,sg)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 跳过主阶段1。
			Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
			-- 跳过战斗阶段。
			Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			-- 跳过主阶段2。
			Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
			-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册场效果，禁止战斗阶段。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 定义thfilter2函数，用于筛选可以作为回收对象的卡片。
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsSetCard(0x146) and c:IsAbleToHand() and c:IsAbleToDeck()
end
-- 定义thtg函数，选择墓地中符合条件的卡片作为目标。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	-- 检查目标是否在墓地且为当前玩家控制，并满足s.thfilter2的条件。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,2,c) end
	-- 提示玩家选择效果的目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从墓地选择符合条件的卡片。
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,2,2,c)
	-- 设置操作信息，表示将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息，表示将一张卡返回卡组最下面。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 定义thop函数，实现回收效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中相关的目标卡片组。
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		if tg:GetCount()==1 then
			if tg:IsExists(Card.IsAbleToHand,1,nil) then
				-- 将目标卡送入手牌。
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 确认送去对方场上的卡片。
				Duel.ConfirmCards(1-tp,tg)
			end
		else
			-- 提示玩家选择要加入手牌的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			if sg:IsExists(Card.IsAbleToHand,1,nil) then
				tg:Sub(sg)
				-- 将选定的卡送入手牌。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 确认送去对方场上的卡片。
				Duel.ConfirmCards(1-tp,sg)
				if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
					-- 将剩余的卡返回卡组最下面。
					Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end
