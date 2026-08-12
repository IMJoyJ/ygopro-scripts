--メルフィーがころんだ
-- 效果：
-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
local s,id,o=GetID()
-- 初始化效果：注册①效果（魔陷发动、自由时点、检索加手）和②效果（墓地起动、取对象、回收加手/回卡组），并登记特殊召唤计数器
function s.initial_effect(c)
	-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
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
	-- 设置②效果的代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 登记特殊召唤计数器：每当自己把非「童话动物」怪兽特殊召唤时计数加1
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：特殊召唤的怪兽是「童话动物」且表侧表示时不计数
function s.counterfilter(c)
	return c:IsSetCard(0x146) and c:IsFaceup()
end
-- ①效果的发动条件/誓约：本回合未特殊召唤过非「童话动物」怪兽，且发动后直到回合结束自己不能特殊召唤非「童话动物」怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：本回合自己特殊召唤非「童话动物」怪兽的次数为0才能发动
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把「不能特殊召唤」的誓约效果注册给自己玩家，直到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 誓约限制函数：非「童话动物」怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x146)
end
-- 检索过滤函数：卡组中可以加入手卡的「童话动物」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的对象/目标设置：确认卡组存在可检索的「童话动物」怪兽并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：卡组存在至少1只可以加入手卡的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡（检索分类）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选最多4只卡名不同的「童话动物」怪兽加入手卡，然后跳过主要阶段1、战斗阶段和主要阶段2，并注册不能进入战斗阶段的效果，变成回合结束阶段
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有可以加入手卡的「童话动物」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组怪兽中选出1~4只卡名互不相同的「童话动物」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,4)
	-- 把选出的怪兽加入手卡，且实际有卡被加入手卡时继续处理
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,sg)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 跳过这个回合的主要阶段1
			Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
			-- 跳过这个回合的战斗阶段
			Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			-- 跳过这个回合的主要阶段2
			Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
			-- 那之后，变成这个回合的结束阶段。②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 把「不能进入战斗阶段」的效果注册给自己玩家，直到回合结束
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- ②效果对象过滤函数：「童话动物木头人游戏」以外的自己墓地可以加入手卡也可以回到卡组的「童话动物」卡
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsSetCard(0x146) and c:IsAbleToHand() and c:IsAbleToDeck()
end
-- ②效果的对象设置：以自己墓地2张符合条件的「童话动物」卡为对象，并设置加手与回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	-- 发动条件检测：自己墓地存在2张可以作为对象的符合条件的「童话动物」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,2,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地2张「童话动物木头人游戏」以外的「童话动物」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,2,2,c)
	-- 设置操作信息：作为对象的卡中1张将加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：作为对象的卡中1张将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取得仍与连锁关联的对象卡，1张时直接加入手卡；2张时选1张加入手卡，另1张回到卡组最下面
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁关联的对象卡，并过滤掉受王家长眠之谷影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		if tg:GetCount()==1 then
			if tg:IsExists(Card.IsAbleToHand,1,nil) then
				-- 把对象卡加入手卡
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 把加入手卡的卡给对方确认
				Duel.ConfirmCards(1-tp,tg)
			end
		else
			-- 提示玩家选择要加入手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			if sg:IsExists(Card.IsAbleToHand,1,nil) then
				tg:Sub(sg)
				-- 把选出的那1张卡加入手卡
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 把加入手卡的卡给对方确认
				Duel.ConfirmCards(1-tp,sg)
				if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
					-- 把剩下的另1张卡回到持有者卡组最下面
					Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end
