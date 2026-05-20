--ドテドテング
-- 效果：
-- 这张卡被对方的卡的效果送去墓地的场合，选择对方场上1张卡才能发动。选择的卡回到持有者手卡。
function c82050203.initial_effect(c)
	-- 这张卡被对方的卡的效果送去墓地的场合，选择对方场上1张卡才能发动。选择的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82050203,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c82050203.retcon)
	e1:SetTarget(c82050203.rettg)
	e1:SetOperation(c82050203.retop)
	c:RegisterEffect(e1)
end
-- 验证发动条件：此卡因对方卡的效果送去墓地，且送去墓地前由自身控制
function c82050203.retcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动的目标选择：验证是否存在合法的对方场上卡片，并进行取对象操作与设置操作信息
function c82050203.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 在发动效果的准备阶段，检查对方场上是否存在至少1张可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家提示选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的卡片作为返回手牌的对象，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：获取效果对象，若该卡仍存在于场上，则将其送回持有者手牌
function c82050203.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时所选择的第1个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
