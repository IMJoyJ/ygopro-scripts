--カバリスト
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以支付800基本分从自己卡组把1只念动力族怪兽加入手卡。
function c22171591.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以支付800基本分从自己卡组把1只念动力族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22171591,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22171591.condition)
	e1:SetCost(c22171591.cost)
	e1:SetTarget(c22171591.target)
	e1:SetOperation(c22171591.operation)
	c:RegisterEffect(e1)
end
-- 检查效果发动者是否在墓地且因战斗破坏而送去墓地，满足“这张卡被战斗破坏送去墓地时”的触发条件。
function c22171591.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义发动代价：先检查能否支付800基本分，能则支付800基本分作为发动代价。
function c22171591.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认玩家可以支付800基本分，若可以则允许发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 定义检索卡的过滤条件：需要是念动力族怪兽且能够加入手卡。
function c22171591.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- 效果发动时设定目标：从自己卡组选择1只符合条件的念动力族怪兽加入手卡，并设置对应的操作信息。
function c22171591.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己卡组中存在至少1只符合条件的念动力族怪兽，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c22171591.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时，将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从自己卡组选择1只念动力族怪兽加入手卡，并将加入手卡的卡展示给对方确认。
function c22171591.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只符合条件的念动力族怪兽。
	local g=Duel.SelectMatchingCard(tp,c22171591.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的念动力族怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
