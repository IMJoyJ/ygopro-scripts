--貪欲で無欲な壺
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：自己主要阶段1开始时，以自己墓地3只怪兽为对象才能发动（相同种族最多1只）。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
function c98672567.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：自己主要阶段1开始时，以自己墓地3只怪兽为对象才能发动（相同种族最多1只）。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c98672567.condition)
	e1:SetCost(c98672567.cost)
	e1:SetTarget(c98672567.target)
	e1:SetOperation(c98672567.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查本回合是否未进入战斗阶段，且当前处于阶段开始时（主要阶段1开始时）。
function c98672567.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否未进行过战斗阶段，且当前处于阶段开始时（主要阶段1开始时）。
	return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 and not Duel.CheckPhaseActivity()
end
-- 发动代价（Cost）：注册本回合不能进行战斗阶段的限制效果。
function c98672567.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：自己主要阶段1开始时，以自己墓地3只怪兽为对象才能发动（相同种族最多1只）。那3只怪兽回到卡组洗切。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册“不能进行战斗阶段”的誓约效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：筛选墓地中可以作为效果对象且能回到卡组的怪兽。
function c98672567.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 效果发动目标（Target）：检查是否能抽卡、墓地是否有3个不同种族的怪兽，并选择3只怪兽作为对象，设置操作信息。
function c98672567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查玩家当前是否能够从卡组抽2张卡。
		if not Duel.IsPlayerCanDraw(tp,2) then return false end
		-- 获取自己墓地中所有满足条件的怪兽卡组。
		local g=Duel.GetMatchingGroup(c98672567.filter,tp,LOCATION_GRAVE,0,nil,e)
		return g:GetClassCount(Card.GetRace)>=3
	end
	-- 获取自己墓地中所有满足条件的怪兽卡组，准备进行选择。
	local g=Duel.GetMatchingGroup(c98672567.filter,tp,LOCATION_GRAVE,0,nil,e)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从符合条件的怪兽中选择3只种族互不相同的怪兽。
	local g1=g:SelectSubGroup(tp,aux.drccheck,false,3,3)
	-- 将选中的3只怪兽设置为效果的对象。
	Duel.SetTargetCard(g1)
	-- 设置连锁操作信息：将选中的3张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
	-- 设置连锁操作信息：玩家从卡组抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理（Operation）：将作为对象的3只怪兽送回卡组洗切，若成功送回3张，则从卡组抽2张卡。
function c98672567.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将作为对象的怪兽送回持有者卡组并洗牌。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片被送回了主卡组，则洗切玩家的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组视为同时进行。
		Duel.BreakEffect()
		-- 玩家从卡组抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
