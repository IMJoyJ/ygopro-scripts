--揺海魚デッドリーフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤时才能发动。从卡组把「摇海鱼 枯叶海龙」以外的1只鱼族怪兽送去墓地。
-- ②：把墓地的这张卡除外，以自己墓地3只鱼族怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
function c89617515.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤时才能发动。从卡组把「摇海鱼 枯叶海龙」以外的1只鱼族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89617515,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,89617515)
	e1:SetTarget(c89617515.target)
	e1:SetOperation(c89617515.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把墓地的这张卡除外，以自己墓地3只鱼族怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89617515,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,89617516)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c89617515.drtg)
	e4:SetOperation(c89617515.drop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中除「摇海鱼 枯叶海龙」以外的鱼族怪兽且能送去墓地的卡片
function c89617515.tgfilter(c)
	return c:IsRace(RACE_FISH) and not c:IsCode(89617515) and c:IsAbleToGrave()
end
-- ①号效果的发动准备与检测，检查卡组中是否存在可送去墓地的鱼族怪兽，并设置送去墓地的操作信息
function c89617515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只除「摇海鱼 枯叶海龙」以外的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89617515.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理，从卡组选择1只满足条件的鱼族怪兽送去墓地
function c89617515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,c89617515.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤墓地中可以回到卡组的鱼族怪兽
function c89617515.tdfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToDeck()
end
-- ②号效果的发动准备与检测，检查玩家是否能抽卡、墓地是否有3只鱼族怪兽作为对象，并进行取对象和设置操作信息
function c89617515.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少3只可以回到卡组的鱼族怪兽（排除自身）
		and Duel.IsExistingTarget(c89617515.tdfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地3只鱼族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c89617515.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置当前连锁的操作信息为：将选中的3张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②号效果的实际处理，将对象怪兽回到卡组并洗卡，那之后抽1张卡
function c89617515.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象怪兽送回持有者的卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片实际回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行
		Duel.BreakEffect()
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
