--マドルチェ・クロワンサン
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。此外，1回合1次，选择这张卡以外的自己场上1张名字带有「魔偶甜点」的卡才能发动。选择的卡回到手卡，这张卡的等级上升1星，攻击力上升300。
function c89521713.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89521713,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c89521713.retcon)
	e1:SetTarget(c89521713.rettg)
	e1:SetOperation(c89521713.retop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，选择这张卡以外的自己场上1张名字带有「魔偶甜点」的卡才能发动。选择的卡回到手卡，这张卡的等级上升1星，攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89521713,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c89521713.thtg)
	e2:SetOperation(c89521713.thop)
	c:RegisterEffect(e2)
end
-- 判定此卡是否被对方破坏并送去墓地。
function c89521713.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动准备，设置操作信息为将自身送回卡组。
function c89521713.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为将此卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理，将此卡送回卡组。
function c89521713.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡送回持有者卡组并洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示且能回到手牌的「魔偶甜点」卡片。
function c89521713.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsAbleToHand()
end
-- 效果发动准备，选择自己场上除自身以外的1张表侧表示「魔偶甜点」卡片作为对象，并设置操作信息。
function c89521713.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c89521713.filter(chkc) end
	-- 检查自己场上是否存在除自身以外、可以回到手牌的表侧表示「魔偶甜点」卡片。
	if chk==0 then return Duel.IsExistingTarget(c89521713.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上除自身以外的1张表侧表示「魔偶甜点」卡片作为效果对象。
	local g=Duel.SelectTarget(tp,c89521713.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置当前连锁的操作信息为将选择的对象卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，将选择的对象卡送回手牌，若成功则此卡等级上升1星，攻击力上升300。
function c89521713.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍适用效果且表侧表示，并将其送回手牌，确认其成功回到手牌。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的等级上升1星
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(300)
			c:RegisterEffect(e2)
		end
	end
end
