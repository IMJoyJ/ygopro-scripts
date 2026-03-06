--マドルチェ・マーマメイド
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡反转时，可以选择自己墓地1张名字带有「魔偶甜点」的魔法·陷阱卡加入手卡。
function c26016357.initial_effect(c)
	-- 效果原文：这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26016357,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c26016357.retcon)
	e1:SetTarget(c26016357.rettg)
	e1:SetOperation(c26016357.retop)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡反转时，可以选择自己墓地1张名字带有「魔偶甜点」的魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26016357,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c26016357.thtg)
	e2:SetOperation(c26016357.thop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否因对方破坏而送去墓地，且之前在自己控制下。
function c26016357.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 规则层面：设置效果处理时将自身送回卡组的操作信息。
function c26016357.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置当前连锁操作为将目标卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 规则层面：执行将自身送回卡组的操作。
function c26016357.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面：将自身以效果原因送回卡组并洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 规则层面：定义过滤器，用于筛选墓地中的魔偶甜点魔法或陷阱卡。
function c26016357.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 规则层面：设置反转时的效果目标选择与操作信息。
function c26016357.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26016357.filter(chkc) end
	-- 规则层面：检查是否存在满足条件的墓地目标卡。
	if chk==0 then return Duel.IsExistingTarget(c26016357.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的墓地目标卡。
	local g=Duel.SelectTarget(tp,c26016357.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面：设置当前连锁操作为将目标卡送入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面：执行将目标卡送入手牌的操作。
function c26016357.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁处理的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标卡以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面：向对方确认目标卡的加入手牌动作。
		Duel.ConfirmCards(1-tp,tc)
	end
end
