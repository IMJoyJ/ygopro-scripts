--心太砲式
-- 效果：
-- ①：自己或者对方的怪兽的攻击宣言时，以场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
function c41440817.initial_effect(c)
	-- ①：自己或者对方的怪兽的攻击宣言时，以场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c41440817.target)
	e1:SetOperation(c41440817.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择处理：确认存在可成为对象的场上怪兽，选择1只场上怪兽作为效果对象，并设置将1张卡返回卡组的操作信息。
function c41440817.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToDeck() end
	-- 判定场上是否存在至少1只可以返回卡组的怪兽，作为效果发动的合法对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 由玩家从双方主要怪兽区选择1只可以返回卡组的怪兽，并指定为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记当前连锁的处理信息：将1张对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理时的操作：取得对象怪兽，若对象仍与该效果关联，则将其送回持有者卡组。
function c41440817.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组，并触发卡组洗切。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
