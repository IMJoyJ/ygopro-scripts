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
-- 效果作用：检查触发条件是否满足（卡片在墓地且因战斗破坏）
function c22171591.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果作用：支付800基本分
function c22171591.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 效果作用：支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 效果作用：定义检索卡片的过滤条件（念动力族且能加入手牌）
function c22171591.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- 效果作用：设置效果目标，检查卡组中是否存在满足条件的卡片
function c22171591.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c22171591.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息，指定将要处理的卡牌类别为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行效果处理，选择并加入手牌
function c22171591.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c22171591.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
