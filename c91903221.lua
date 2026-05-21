--エヴォルド・エルギネル
-- 效果：
-- 场上的这张卡被解放送去墓地时，从卡组抽1张卡。那之后，可以让手卡1只恐龙族怪兽回到卡组，从卡组把1只名字带有「进化虫」的怪兽加入手卡。
function c91903221.initial_effect(c)
	-- 场上的这张卡被解放送去墓地时，从卡组抽1张卡。那之后，可以让手卡1只恐龙族怪兽回到卡组，从卡组把1只名字带有「进化虫」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91903221,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCondition(c91903221.condition)
	e1:SetTarget(c91903221.target)
	e1:SetOperation(c91903221.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：此卡是否在场上被解放并送去墓地。
function c91903221.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤条件：手牌中可以回到卡组的恐龙族怪兽。
function c91903221.filter1(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中可以加入手牌的「进化虫」怪兽。
function c91903221.filter2(c)
	return c:IsSetCard(0x304e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标确认，因为是必发效果所以直接返回true，并设置抽卡的操作信息。
function c91903221.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：由玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的核心逻辑：先执行抽卡，再根据玩家意愿决定是否让手牌的恐龙族怪兽回到卡组并检索「进化虫」怪兽。
function c91903221.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家因效果抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 获取玩家手牌中满足条件的恐龙族怪兽组。
	local g1=Duel.GetMatchingGroup(c91903221.filter1,tp,LOCATION_HAND,0,nil)
	-- 获取玩家卡组中满足条件的「进化虫」怪兽组。
	local g2=Duel.GetMatchingGroup(c91903221.filter2,tp,LOCATION_DECK,0,nil)
	-- 判断手牌和卡组中是否存在符合条件的卡，并询问玩家是否进行后续的“手牌回卡组并检索”操作。
	if g1:GetCount()>0 and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91903221,1)) then  --"是否要把1只名字带有「进化虫」的怪兽加入手卡？"
		-- 中断当前效果处理，使前后的抽卡与回卡组/检索处理不视为同时进行（造成错时点）。
		Duel.BreakEffect()
		-- 提示玩家选择要送回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg1=g1:Select(tp,1,1,nil)
		-- 给对方玩家确认要送回卡组的卡。
		Duel.ConfirmCards(1-tp,tg1)
		-- 将选中的手牌怪兽送回卡组并洗牌。
		Duel.SendtoDeck(tg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg2=g2:Select(tp,1,1,nil)
		-- 将选中的「进化虫」怪兽从卡组加入手牌。
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tg2)
	end
end
