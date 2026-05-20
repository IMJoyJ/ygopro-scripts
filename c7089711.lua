--ハネハネ
-- 效果：
-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
function c7089711.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7089711,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c7089711.target)
	e1:SetOperation(c7089711.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的处理：进行对象选择的合法性检测，并选择场上1只可以回到手牌的怪兽作为对象，注册对应的操作信息
function c7089711.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向发动效果的玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择双方场上1只可以回到手牌的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：获取发动时选择的对象，若该卡仍与此效果有关联，则将其送回持有者的手牌
function c7089711.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
