--アスワンの亡霊
-- 效果：
-- 这张卡对对方造成战斗伤害时，可以将自己墓地里的1张陷阱卡弹回卡组最上面。
function c88236094.initial_effect(c)
	-- 这张卡对对方造成战斗伤害时，可以将自己墓地里的1张陷阱卡弹回卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88236094,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c88236094.condition)
	e1:SetTarget(c88236094.target)
	e1:SetOperation(c88236094.operation)
	c:RegisterEffect(e1)
end
-- 判定受到战斗伤害的玩家是否为对方玩家。
function c88236094.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：自己墓地中可以返回卡组的陷阱卡。
function c88236094.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果发动的目标选择与检测，确认墓地中存在符合条件的陷阱卡并选择其作为对象。
function c88236094.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88236094.filter(chkc) end
	-- 在发动阶段，检测自己墓地是否存在至少1张符合条件的陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c88236094.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张符合条件的陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c88236094.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示将有1张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将作为对象的陷阱卡送回卡组最上面。
function c88236094.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送回持有者卡组的最上面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
