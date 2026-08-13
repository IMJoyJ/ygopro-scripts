--青き眼の威光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「青眼」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在不能攻击。
function c2783661.initial_effect(c)
	-- 该卡名的卡在1回合只能发动1张；①：从手卡·卡组把1只「青眼」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动，那只怪兽只要在场上表侧表示存在不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,2783661+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c2783661.cost)
	e1:SetTarget(c2783661.target)
	e1:SetOperation(c2783661.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否满足「青眼」系列（0xdd）且可以作为代价送去墓地。
function c2783661.filter(c)
	return c:IsSetCard(0xdd) and c:IsAbleToGraveAsCost()
end
-- 代价函数：从手卡·卡组选择1只「青眼」怪兽送去墓地作为发动代价。
function c2783661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：若在发动确认阶段，检查是否存在至少1张满足条件的「青眼」怪兽在手卡·卡组，以判断代价是否可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c2783661.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡·卡组中选择1张满足条件的「青眼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c2783661.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数：设定效果对象，选择场上1只表侧表示怪兽。
function c2783661.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 目标合法性检查：若在发动确认阶段，检查场上是否存在至少1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示怪兽作为对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：对仍与效果相关且表侧表示的对象怪兽赋予不能攻击的效果。
function c2783661.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽只要在场上表侧表示存在不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
