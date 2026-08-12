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
-- 检查此效果的发动条件，即这张卡是否从场上送去墓地
function c75043725.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动时的目标处理，由于是必发效果直接返回true，并设置操作信息
function c75043725.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，筛选等级3以下、属于通常怪兽且可以加入手牌的卡
function c75043725.filter(c)
	return c:IsLevelBelow(3) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果处理的执行函数，双方玩家各自从卡组选择符合条件的卡，加入手牌并向对方确认
function c75043725.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给回合玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让回合玩家从自己的卡组中选择1张满足过滤条件的卡
	local g1=Duel.SelectMatchingCard(tp,c75043725.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc1=g1:GetFirst()
	-- 给对方玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让对方玩家从其自己的卡组中选择1张满足过滤条件的卡
	local g2=Duel.SelectMatchingCard(1-tp,c75043725.filter,tp,0,LOCATION_DECK,1,1,nil)
	local tc2=g2:GetFirst()
	g1:Merge(g2)
	-- 将双方选中的卡因效果加入各自持有者的手牌
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 如果回合玩家成功选择了卡，则向对方玩家展示并确认该卡
	if tc1 then Duel.ConfirmCards(1-tp,tc1) end
	-- 如果对方玩家成功选择了卡，则向回合玩家展示并确认该卡
	if tc2 then	Duel.ConfirmCards(tp,tc2) end
end
