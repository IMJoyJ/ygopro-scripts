--バード・フェイス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
function c45547649.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
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
-- 判定触发条件：此卡处于墓地且是被战斗破坏送墓的。
function c45547649.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索过滤条件：卡名是「鹰身女郎」（卡号76812113）且可以被加入手卡。
function c45547649.filter(c)
	return c:IsCode(76812113) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：确认卡组存在符合条件的「鹰身女郎」，并设置本次操作信息为从卡组将1张卡加入手卡。
function c45547649.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查（chk==0），确认自己卡组中存在至少1张可加入手卡的「鹰身女郎」。
	if chk==0 then return Duel.IsExistingMatchingCard(c45547649.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将执行从卡组将1张卡加入手卡的处理，用于后续时点与效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张「鹰身女郎」加入手卡，并向对方展示该卡。
function c45547649.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家从卡组选择要加入手卡的卡（弹出选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张满足检索过滤条件的「鹰身女郎」。
	local g=Duel.SelectMatchingCard(tp,c45547649.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「鹰身女郎」以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张「鹰身女郎」展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
