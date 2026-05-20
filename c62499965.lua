--Z－ONE
-- 效果：
-- ①：盖放的这张卡被破坏送去墓地的场合，以自己墓地1张永续魔法卡或者场地魔法卡为对象发动。那张卡加入手卡。
function c62499965.initial_effect(c)
	-- ①：盖放的这张卡被破坏送去墓地的场合，以自己墓地1张永续魔法卡或者场地魔法卡为对象发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62499965,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c62499965.thcon)
	e1:SetTarget(c62499965.thtg)
	e1:SetOperation(c62499965.thop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否在场上盖放的状态下被破坏并送去墓地
function c62499965.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤自己墓地中可以加入手牌的永续魔法卡或场地魔法卡
function c62499965.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 效果发动的对象选择与效果处理信息设置（由于是必发效果，chk==0时直接返回true）
function c62499965.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62499965.filter(chkc) end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的永续魔法卡或场地魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c62499965.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为“将选中的卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时，将作为对象的卡加入手牌并给对方玩家确认
function c62499965.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
