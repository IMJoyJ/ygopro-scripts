--苦渋の選択
-- 效果：
-- 从卡组选择5张卡给对方看。对方从这些卡中选择1张。对方选择的卡加入自己手卡，其他的卡丢弃去墓地。
function c74191942.initial_effect(c)
	-- 从卡组选择5张卡给对方看。对方从这些卡中选择1张。对方选择的卡加入自己手卡，其他的卡丢弃去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74191942.target)
	e1:SetOperation(c74191942.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：玩家是否能将卡组的卡送去墓地，且卡组中是否存在至少5张可以加入手牌的卡
function c74191942.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以把卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己卡组中是否存在至少5张可以加入手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,5,nil) end
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选5张卡给对方确认，对方选1张加入自己手牌，其余卡送去墓地
function c74191942.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查玩家是否可以把卡组的卡送去墓地，若不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 提示自己选择5张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191942,0))  --"请选择５张卡"
	-- 让自己从卡组选择5张可以加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,5,5,nil)
	if g:GetCount()<5 then return end
	-- 将选出的5张卡给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 提示对方选择要加入对方（自己）手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191942,1))  --"请选择要加入对方手牌的卡"
	local sg=g:Select(1-tp,1,1,nil)
	sg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
	-- 将对方选择的1张卡加入自己的手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	g:Sub(sg)
	-- 将剩下的4张卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
