--メルフィーがころんだ
-- 效果：
-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把最多4只「童话动物」怪兽加入手卡（同名卡最多1张）。那之后，变成这个回合的结束阶段。
-- ②：把墓地的这张卡除外，以「童话动物木头人游戏」以外的自己墓地2张「童话动物」卡为对象才能发动。那之内的1张加入手卡，另1张回到卡组最下面。
local s,id,o=GetID()
-- 注册“童话动物木头人游戏”的卡片效果：①魔法卡发动的检索加跳过回合效果，②墓地起动回收2张童话动物卡（1张加入手卡，1张回到卡组最下面）的效果，并设置自召限制计数器
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
	-- 设置Cost：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于检测玩家在当前回合是否特殊召唤过非「童话动物」怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤条件：非表侧表示存在的「童话动物」怪兽的特殊召唤检测
function s.counterfilter(c)
	return c:IsSetCard(0x146) and c:IsFaceup()
end
-- 效果①的发动Cost：检查本回合至今自己是否只特殊召唤过「童话动物」怪兽，并为自己施加「本回合不能特殊召唤非童话动物怪兽」的誓约效果
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断本回合至今自己特殊召唤非「童话动物」怪兽的次数是否为0
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「童话动物」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将此自召限制效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：不能特殊召唤非「童话动物」的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x146)
end
-- 过滤条件：卡组中的「童话动物」怪兽，且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：判断自己卡组中是否存在「童话动物」怪兽，并设置将卡组中的卡片加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组中是否存在可以加入手卡的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的操作处理：从卡组将最多4只卡名不同的「童话动物」怪兽加入手卡，那之后直接跳过各个阶段变成这个回合的结束阶段
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合加入手卡条件的「童话动物」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 给玩家发送提示：请选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1到4张卡名互不相同的符合条件的卡片
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,4)
	-- 若成功选择并将至少1张卡加入玩家手卡
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 将加入手卡的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 跳过玩家的主阶段1，将其重置时间设为回合结束
			Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
			-- 跳过玩家的战斗阶段，将其重置时间设为回合结束
			Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			-- 跳过玩家的主阶段2，将其重置时间设为回合结束
			Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
			-- 那之后，变成这个回合的结束阶段。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将「不能进行战斗阶段」的效果注册给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 过滤条件：自己墓地中除了「童话动物木头人游戏」以外的「童话动物」卡片，且可以加入手卡和卡组
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsSetCard(0x146) and c:IsAbleToHand() and c:IsAbleToDeck()
end
-- 效果②的发动准备：以自己墓地除此卡以外的2张「童话动物」卡为对象发动，并设置加入手卡和回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	-- 判断自己墓地是否存在至少2张符合条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,2,c) end
	-- 给玩家发送提示：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家在墓地选择2张符合条件的卡片作为效果对象并记录
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,2,2,c)
	-- 设置操作信息：将1张对象卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将1张对象卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的操作处理：对于选中的2张卡片，让玩家选择其中1张加入手卡，另1张回到卡组最下面
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		if tg:GetCount()==1 then
			if tg:IsExists(Card.IsAbleToHand,1,nil) then
				-- 若只有1张对象卡依然有效，则直接将其加入玩家手卡并展示
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 将被选择加入手卡的单张卡展示给对方确认
				Duel.ConfirmCards(1-tp,tg)
			end
		else
			-- 给玩家发送提示：请选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			if sg:IsExists(Card.IsAbleToHand,1,nil) then
				tg:Sub(sg)
				-- 将玩家选中的那张对象卡加入手卡
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 将选中的那张加入手卡的卡片展示给对方确认
				Duel.ConfirmCards(1-tp,sg)
				if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
					-- 将另一张对象卡送回玩家卡组的最底端
					Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end
