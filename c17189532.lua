--ファントム・バウンサー
-- 效果：
-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把2张名字带有「保镖」的卡加入手卡。
function c17189532.initial_effect(c)
	-- 创建效果，设置为场上的这张卡被破坏送去墓地时发动的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17189532,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c17189532.condition)
	e1:SetTarget(c17189532.target)
	e1:SetOperation(c17189532.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是从场上被破坏送去墓地时
function c17189532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：名字带有「保镖」的卡且可以加入手牌
function c17189532.filter(c)
	return c:IsSetCard(0x6b) and c:IsAbleToHand()
end
-- 效果目标设定：检查卡组中是否存在至少2张名字带有「保镖」的卡
function c17189532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果发动条件：卡组中存在至少2张名字带有「保镖」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17189532.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置效果处理信息：将2张名字带有「保镖」的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：检索满足条件的卡并选择2张加入手牌
function c17189532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的卡
	local sg=Duel.GetMatchingGroup(c17189532.filter,tp,LOCATION_DECK,0,nil)
	if sg:GetCount()<2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=sg:Select(tp,2,2,nil)
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
