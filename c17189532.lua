--ファントム・バウンサー
-- 效果：
-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把2张名字带有「保镖」的卡加入手卡。
function c17189532.initial_effect(c)
	-- 对应效果原文：场上的这张卡被破坏送去墓地的场合，可以从卡组把2张名字带有「保镖」的卡加入手卡。
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
-- 判定效果发动条件：触发时必须满足这张卡在被破坏送去墓地前位于场上，且此次是被“破坏”的原因送去墓地。
function c17189532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选符合条件的卡片：卡名含有「保镖」字段（0x6b）且能够加入手卡。
function c17189532.filter(c)
	return c:IsSetCard(0x6b) and c:IsAbleToHand()
end
-- 效果发动时的目标设定：检查卡组是否存在至少2张符合条件的「保镖」卡，若存在则设置本次操作信息为从卡组将2张卡加入手卡。
function c17189532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若chk==0（发动时点检查）时卡组中没有至少2张满足条件的「保镖」卡，则不能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c17189532.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置操作信息，向系统声明该效果处理时会将2张卡从卡组加入手卡，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：获取卡组中所有符合条件的「保镖」卡，若不足2张则效果不处理；否则由玩家选择2张加入手卡，并向对方展示。
function c17189532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足筛选条件的「保镖」卡，作为后续选择的候选集合。
	local sg=Duel.GetMatchingGroup(c17189532.filter,tp,LOCATION_DECK,0,nil)
	if sg:GetCount()<2 then return end
	-- 显示选择提示消息，提示玩家从候选卡中选择要加入手卡的卡（选择框标题为“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=sg:Select(tp,2,2,nil)
	-- 将玩家选中的卡以“效果”的原因送去其持有者的手卡，即加入手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家（1-tp）展示本次加入手卡的卡片，完成检索确认。
	Duel.ConfirmCards(1-tp,g)
end
