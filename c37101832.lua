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
-- 效果的目标选择与发动条件判定：先检查连锁对象是否为对方场上怪兽区且可加入手卡；发动时给出选择提示，从对方场上怪兽区选择1只可加入手卡的怪兽作为对象，并设置回手牌的操作信息。
function c37101832.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 发动时向玩家显示提示信息，要求选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上主要怪兽区选择1只满足可加入手卡条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将选择的对象卡以回手牌分类进行处理，数量为选择卡的张数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理阶段：获取发动时选择的对象卡，若该卡仍与此效果关联，则将其返回持有者手卡。
function c37101832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将该怪兽返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
