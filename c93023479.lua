--墓守の召喚師
-- 效果：
-- 这张卡从自己场上送去自己墓地时，从自己的卡组把1只守备力1500以下的名字带有「守墓」的怪兽加入手卡。
function c93023479.initial_effect(c)
	-- 这张卡从自己场上送去自己墓地时，从自己的卡组把1只守备力1500以下的名字带有「守墓」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93023479,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c93023479.condition)
	e1:SetTarget(c93023479.target)
	e1:SetOperation(c93023479.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：检查这张卡是否是从自己场上送去自己的墓地
function c93023479.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动的目标处理：必发效果直接返回true，并设置从卡组检索的操作信息
function c93023479.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：守备力1500以下、名字带有「守墓」的怪兽，且可以加入手卡
function c93023479.filter(c)
	return c:IsDefenseBelow(1500) and c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组选择1只满足条件的怪兽加入手卡，并给对方确认
function c93023479.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c93023479.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
