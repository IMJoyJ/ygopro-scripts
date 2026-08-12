--混沌の場
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「混沌战士」仪式怪兽或者「暗黑骑士 盖亚」怪兽加入手卡。
-- ②：只要这张卡在场地区域存在，每次从双方的手卡·场上有怪兽被送去墓地，每有1只给这张卡放置1个魔力指示物（最多6个）。
-- ③：1回合1次，把这张卡3个魔力指示物取除才能发动。自己从卡组把1张仪式魔法卡加入手卡。
function c40089744.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,6)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，从卡组把1只「混沌战士」仪式怪兽或者「暗黑骑士 盖亚」怪兽加入手卡。
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
c40089744.mentioned_counter={
	[0x1]=true,
}
-- 检索用过滤器：筛选属于「混沌战士」系列的仪式怪兽或「暗黑骑士 盖亚」系列的、可以加入手卡的怪兽卡
function c40089744.filter(c)
	return ((c:IsSetCard(0x10cf) and c:IsType(TYPE_RITUAL)) or c:IsSetCard(0xbd)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标确认：检查卡组中是否存在可加入手卡的对象卡，并设置从卡组把卡加入手卡的操作信息
function c40089744.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组中至少存在1只满足条件的「混沌战士」仪式怪兽或「暗黑骑士 盖亚」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40089744.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预告将从卡组把1张卡加入手卡（用于星尘龙等效果的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动时的效果处理：让玩家从卡组选择1只满足条件的怪兽加入手卡，并向对方展示确认
function c40089744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」的选择消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组选择1只满足条件的「混沌战士」仪式怪兽或「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,c40089744.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果处理把选择的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡出示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 指示物计数过滤器：筛选从手卡·场上被送去墓地的怪兽卡
function c40089744.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 永续处理：统计本次从双方手卡·场上送去墓地的怪兽数量，每有1只给这张卡放置1个魔力指示物
function c40089744.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c40089744.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x1,ct,true)
	end
end
-- 发动代价：确认并取除这张卡的3个魔力指示物作为效果的发动代价
function c40089744.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 检索用过滤器：筛选可以加入手卡的仪式魔法卡
function c40089744.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 效果目标确认：检查卡组中是否存在可加入手卡的仪式魔法卡，并设置从卡组把卡加入手卡的操作信息
function c40089744.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组中至少存在1张可以加入手卡的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40089744.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预告将从卡组把1张卡加入手卡（用于星尘龙等效果的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1张仪式魔法卡加入手卡，并向对方展示确认
function c40089744.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」的选择消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组选择1张满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c40089744.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果处理把选择的仪式魔法卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡出示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
