--冥界の使者
-- 效果：
-- 当这张卡从场上被送去墓地时，各自从自己的卡组中选择1张3星以下的通常怪兽，相互确认之后分别加入手卡。
function c75043725.initial_effect(c)
	-- 当这张卡从场上被送去墓地时，各自从自己的卡组中选择1张3星以下的通常怪兽，相互确认之后分别加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75043725,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c75043725.condition)
	e1:SetTarget(c75043725.target)
	e1:SetOperation(c75043725.operation)
	c:RegisterEffect(e1)
end
-- 从场上被送去墓地的发动条件
function c75043725.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果目标检查与操作信息
function c75043725.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：3星以下的通常怪兽且可加入手卡
function c75043725.filter(c,p)
	return c:IsLevelBelow(3) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand(p)
end
-- 效果处理函数
function c75043725.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张3星以下的通常怪兽
	local g1=Duel.SelectMatchingCard(tp,c75043725.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	-- 提示对方选择要加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 对方从其卡组选择1张3星以下的通常怪兽
	local g2=Duel.SelectMatchingCard(1-tp,c75043725.filter,tp,0,LOCATION_DECK,1,1,nil,1-tp)
	local tc2=g2:GetFirst()
	if tc1 then
		-- 将选中的怪兽加入自己手卡
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,tc1)
	end
	if tc2 then
		-- 将选中的怪兽加入对方手卡
		Duel.SendtoHand(tc2,nil,REASON_EFFECT,1-tp)
		-- 向自己确认加入手卡的怪兽
		Duel.ConfirmCards(tp,tc2)
	end
end
