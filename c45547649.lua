--バード・フェイス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
function c45547649.initial_effect(c)
	-- 效果原文：这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45547649,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c45547649.condition)
	e1:SetTarget(c45547649.target)
	e1:SetOperation(c45547649.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：检查触发效果的卡是否在墓地且是因为战斗破坏被送去墓地
function c45547649.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面：过滤函数，用于筛选卡号为76812113（鹰身女郎）且可以加入手牌的卡
function c45547649.filter(c)
	return c:IsCode(76812113) and c:IsAbleToHand()
end
-- 规则层面：设置效果目标，检查卡组中是否存在满足条件的卡，并设置操作信息为检索效果
function c45547649.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否满足发动条件，即卡组中是否存在至少1张符合条件的「鹰身女郎」
	if chk==0 then return Duel.IsExistingMatchingCard(c45547649.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置连锁操作信息，指定效果分类为CATEGORY_TOHAND（回手牌）和CATEGORY_SEARCH（检索）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行效果处理，提示选择卡牌并将其加入手牌，同时确认对方查看该卡
function c45547649.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：从卡组中选择1张符合条件的「鹰身女郎」
	local g=Duel.SelectMatchingCard(tp,c45547649.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
