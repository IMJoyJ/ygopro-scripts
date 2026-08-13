--絶神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段，自己对鸟兽族怪兽的召唤·特殊召唤成功的场合，把手卡的这张卡给对方观看才能发动。把1只「斯摩夫」怪兽召唤。
-- ②：这张卡召唤成功的场合，从卡组把1只「斯摩夫」怪兽送去墓地才能发动。从卡组把1张「斯摩夫」魔法·陷阱卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
function c52843699.initial_effect(c)
	-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段，自己对鸟兽族怪兽的召唤成功的场合，把手卡的这张卡给对方观看才能发动。把1只「斯摩夫」怪兽召唤。（特殊召唤成功分支由克隆效果处理）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52843699,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52843699)
	e1:SetCost(c52843699.sumcost)
	e1:SetCondition(c52843699.sumcon)
	e1:SetTarget(c52843699.sumtg)
	e1:SetOperation(c52843699.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤成功的场合，从卡组把1只「斯摩夫」怪兽送去墓地才能发动。从卡组把1张「斯摩夫」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52843699,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,52843700)
	e3:SetCost(c52843699.cost)
	e3:SetTarget(c52843699.target)
	e3:SetOperation(c52843699.operation)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价：检查手牌中的这张卡是否为非公开状态，即需要把手卡的这张卡给对方观看作为发动代价。
function c52843699.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：判断怪兽是否为表侧表示、鸟兽族、怪兽卡，且是由玩家tp（自己）召唤或特殊召唤成功的怪兽。
function c52843699.sumcfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsType(TYPE_MONSTER) and c:IsSummonPlayer(tp)
end
-- ①效果的发动条件：当前是己方回合的主要阶段1或2，且这次召唤/特殊召唤成功的怪兽中存在满足sumcfilter的怪兽。
function c52843699.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是自己，且处于主要阶段1或主要阶段2，才满足①效果的发动时机。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and eg:IsExists(c52843699.sumcfilter,1,nil,tp)
end
-- 可选择召唤的「斯摩夫」怪兽的过滤器：卡名属于「斯摩夫」（0x12d）、是怪兽卡，并且满足通常召唤条件。
function c52843699.filter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end
-- ①效果的目标处理：确认自己手牌或场上是否存在至少1只可通常召唤的「斯摩夫」怪兽，并设置本次操作信息为召唤分类。
function c52843699.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检查自己手牌或场上是否存在至少1只符合filter的「斯摩夫」怪兽，若存在则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 将本次连锁处理信息标记为“召唤”（CATEGORY_SUMMON），表示效果处理时将要进行召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的实际处理：玩家选择1只可通常召唤的「斯摩夫」怪兽，将其进行通常召唤。
function c52843699.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家tp从自己手牌或场上选择1只符合filter的「斯摩夫」怪兽作为召唤对象。
	local g=Duel.SelectMatchingCard(tp,c52843699.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「斯摩夫」怪兽进行通常召唤，ignore_count=true表示不占用每回合的通常召唤次数。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- ②效果代价用的过滤器：卡组中卡名属于「斯摩夫」、是怪兽卡，并且可以作为代价送去墓地。
function c52843699.cfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ②效果的发动代价：从卡组选择1只「斯摩夫」怪兽送去墓地作为代价。
function c52843699.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认卡组中存在至少1只符合cfilter的「斯摩夫」怪兽可以送去墓地作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示选择提示消息“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只符合cfilter的「斯摩夫」怪兽，作为②效果的代价。
	local g=Duel.SelectMatchingCard(tp,c52843699.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的「斯摩夫」怪兽送去墓地，reason为REASON_COST，表示作为代价处理。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果检索目标的过滤器：卡名属于「斯摩夫」（0x12d）、是魔法或陷阱卡，并且可以加入手卡。
function c52843699.thfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标处理：确认卡组中是否存在至少1张符合条件的「斯摩夫」魔法·陷阱卡，并设置操作信息为加入手卡。
function c52843699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检查卡组中是否存在至少1张符合条件的「斯摩夫」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“加入手卡”（CATEGORY_TOHAND），目标位置为卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张符合条件的「斯摩夫」魔法·陷阱卡加入手卡，并向对方展示。
function c52843699.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「斯摩夫」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c52843699.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「斯摩夫」魔法·陷阱卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片，展示本次检索到的「斯摩夫」魔法·陷阱卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
