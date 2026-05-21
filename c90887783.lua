--竜の交感
-- 效果：
-- 把手卡1只龙族怪兽给对方观看，和给人观看的怪兽相同等级的1只龙族怪兽从卡组加入手卡。那之后，给人观看的怪兽回到卡组。
function c90887783.initial_effect(c)
	-- 把手卡1只龙族怪兽给对方观看，和给人观看的怪兽相同等级的1只龙族怪兽从卡组加入手卡。那之后，给人观看的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90887783.target)
	e1:SetOperation(c90887783.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可返回卡组、未公开的龙族怪兽，且卡组中存在与其相同等级、可加入手牌的龙族怪兽
function c90887783.filter1(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck() and not c:IsPublic()
		-- 检查卡组中是否存在与该怪兽等级相同的、可加入手牌的龙族怪兽
		and Duel.IsExistingMatchingCard(c90887783.filter2,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 过滤卡组中与指定等级相同、可加入手牌的龙族怪兽
function c90887783.filter2(c,lv)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(lv) and c:IsAbleToHand()
end
-- 效果发动时的合法性检测与操作信息注册
function c90887783.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测手牌中是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90887783.filter1,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置连锁信息，表示该效果包含将手牌中的卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置连锁信息，表示该效果包含从卡组将卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，包含展示手牌怪兽、检索同等级怪兽、将展示怪兽送回卡组的完整流程
function c90887783.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择1只满足条件的龙族怪兽
	local g1=Duel.SelectMatchingCard(tp,c90887783.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的手牌怪兽给对方玩家观看
	Duel.ConfirmCards(1-tp,g1)
	if g1:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只与展示怪兽等级相同的龙族怪兽
	local g2=Duel.SelectMatchingCard(tp,c90887783.filter2,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetLevel())
	if g2:GetCount()==0 then return end
	-- 中断当前效果处理，使后续的加入手牌操作与之前的展示操作不视为同时处理
	Duel.BreakEffect()
	-- 将选中的卡组怪兽加入手牌，若加入失败则结束效果
	if Duel.SendtoHand(g2,nil,REASON_EFFECT)==0 then return end
	-- 将加入手牌的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,g2)
	-- 中断当前效果处理，使后续的返回卡组操作与加入手牌操作不视为同时处理（对应“那之后”）
	Duel.BreakEffect()
	-- 将最初展示的手牌怪兽送回卡组并洗牌
	Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
