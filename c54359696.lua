--魔導術士 ラパンデ
-- 效果：
-- 这张卡被送去墓地时，从卡组把1只3星的名字带有「魔导」的怪兽加入手卡。
function c54359696.initial_effect(c)
	-- 这张卡被送去墓地时，从卡组把1只3星的名字带有「魔导」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54359696,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c54359696.target)
	e1:SetOperation(c54359696.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级为3且卡名含有「魔导」的、可加入手牌的怪兽
function c54359696.filter(c)
	return c:IsSetCard(0x6e) and c:IsLevel(3) and c:IsAbleToHand()
end
-- 效果发动的目标处理，作为强制诱发效果直接返回true，并设置将卡组的卡加入手牌的操作信息
function c54359696.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行，从卡组将1只符合条件的怪兽加入手牌并给对方确认
function c54359696.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c54359696.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
