--青き眼の威光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「青眼」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在不能攻击。
function c2783661.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：过滤出满足条件的「青眼」怪兽
function c2783661.filter(c)
	return c:IsSetCard(0xdd) and c:IsAbleToGraveAsCost()
end
-- 效果作用：支付发动代价，将满足条件的「青眼」怪兽送去墓地
function c2783661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足发动代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c2783661.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的「青眼」怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c2783661.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 效果作用：将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果原文内容：①：从手卡·卡组把1只「青眼」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。
function c2783661.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 效果作用：检查场上是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 效果作用：选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果原文内容：那只怪兽只要在场上表侧表示存在不能攻击。
function c2783661.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果作用：给对象怪兽添加不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
