--墓守の番兵
-- 效果：
-- 反转：对方场上1只怪兽回到持有者的手卡。
function c37101832.initial_effect(c)
	-- 反转：对方场上1只怪兽回到持有者的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37101832,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37101832.target)
	e1:SetOperation(c37101832.operation)
	c:RegisterEffect(e1)
end
-- 选择对方场上的1只可以送入手卡的怪兽作为效果对象
function c37101832.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以送入手卡的怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息为将1只怪兽送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将选中的怪兽送入持有者的手卡
function c37101832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
