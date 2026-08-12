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
-- 检索满足条件的怪兽并选择目标
function c41440817.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToDeck() end
	-- 检查是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上一只可以送回卡组的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息，确定将要送回卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 将选中的怪兽送回持有者卡组
function c41440817.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
