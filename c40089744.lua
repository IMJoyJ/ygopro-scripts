--混沌の場
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「混沌战士」仪式怪兽或者「暗黑骑士 盖亚」怪兽加入手卡。
-- ②：只要这张卡在场地区域存在，每次从双方的手卡·场上有怪兽被送去墓地，每有1只给这张卡放置1个魔力指示物（最多6个）。
-- ③：1回合1次，把这张卡3个魔力指示物取除才能发动。自己从卡组把1张仪式魔法卡加入手卡。
function c40089744.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,6)
	-- ①：作为这张卡的发动时的效果处理，从卡组把1只「混沌战士」仪式怪兽或者「暗黑骑士 盖亚」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40089744+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c40089744.target)
	e1:SetOperation(c40089744.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，每次从双方的手卡·场上有怪兽被送去墓地，每有1只给这张卡放置1个魔力指示物（最多6个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c40089744.acop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡3个魔力指示物取除才能发动。自己从卡组把1张仪式魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c40089744.thcost)
	e3:SetTarget(c40089744.thtg)
	e3:SetOperation(c40089744.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的「混沌战士」仪式怪兽或「暗黑骑士 盖亚」怪兽
function c40089744.filter(c)
	return ((c:IsSetCard(0x10cf) and c:IsType(TYPE_RITUAL)) or c:IsSetCard(0xbd)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的判断条件，检查是否满足检索条件
function c40089744.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40089744.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要执行回手牌和检索卡组的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时的处理函数，用于选择并把符合条件的卡加入手牌
function c40089744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c40089744.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断被送去墓地的卡是否为怪兽且来自手牌或场上
function c40089744.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 当有卡送去墓地时，根据送去墓地的怪兽数量为混沌场放置对应数量的魔力指示物
function c40089744.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c40089744.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x1,ct,true)
	end
end
-- 发动效果时的处理函数，用于移除3个魔力指示物作为代价
function c40089744.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 过滤函数，用于检索满足条件的仪式魔法卡
function c40089744.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 效果处理时的判断条件，检查是否满足检索条件
function c40089744.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40089744.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要执行回手牌和检索卡组的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时的处理函数，用于选择并把符合条件的卡加入手牌
function c40089744.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c40089744.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
