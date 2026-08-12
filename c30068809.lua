--魔救の合縁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「魔救」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册效果e1（魔法卡发动的自由时点检索效果，从卡组把「魔救」怪兽加入手卡，同名卡1回合1次）和效果e2（墓地存在的起动效果，以让1张手卡回到卡组最上面为代价把这张卡加入手卡，同名卡1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把1只「魔救」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选「魔救」字段的、可以加入手卡的怪兽卡
function s.thfilter(c)
	return c:IsSetCard(0x140) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- e1的目标函数：确认卡组存在满足条件的「魔救」怪兽，并设置从卡组把卡加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己卡组中是否存在至少1只满足条件的「魔救」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告本连锁处理时将从卡组把1张卡加入手卡（处理的卡处理时才确定，故目标为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- e1的效果处理：让玩家从卡组选1只「魔救」怪兽加入手卡，并向对方确认该卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组选择1只满足条件的「魔救」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因把选中的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选可以回到卡组作为代价的卡
function s.cfilter(c)
	return c:IsAbleToDeckAsCost()
end
-- e2的代价函数：确认手卡存在可回到卡组的卡，让玩家选1张手卡并以代价原因使其回到卡组最上面
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：自己手卡中是否存在至少1张可以回到卡组作为代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己手卡选择1张要回到卡组作为代价的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 为选中的卡显示被选中的动画效果并记录这些卡
	Duel.HintSelection(g)
	-- 以代价原因把选中的手卡回到卡组最上面
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- e2的目标函数：确认这张卡可以加入手卡，并设置把这张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：宣告本连锁处理时将把这张卡（自身）加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- e2的效果处理：若这张卡与连锁相关联且不受王家长眠之谷影响，则把这张卡加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测这张卡是否与当前连锁相关联且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果原因把这张卡加入持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
