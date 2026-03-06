--墓守の伏兵
-- 效果：
-- 这张卡反转时，可以选择对方墓地1张卡回到卡组最下面。此外，反转过的这张卡被送去墓地的场合，可以选择自己墓地1张名字带有「王家长眠之谷」的卡加入手卡。这张卡的效果不会被「王家长眠之谷」的效果无效化。
function c22134079.initial_effect(c)
	-- 这张卡反转时，可以选择对方墓地1张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22134079,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FLIP)
	e1:SetTarget(c22134079.tdtg)
	e1:SetOperation(c22134079.tdop)
	c:RegisterEffect(e1)
	-- 反转过的这张卡被送去墓地的场合，可以选择自己墓地1张名字带有「王家长眠之谷」的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c22134079.flipop)
	c:RegisterEffect(e2)
	-- 这张卡的效果不会被「王家长眠之谷」的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22134079,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c22134079.thcon)
	e3:SetTarget(c22134079.thtg)
	e3:SetOperation(c22134079.thop)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e4)
end
-- 效果原文内容
function c22134079.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息为回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果作用
function c22134079.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入卡组底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 效果作用
function c22134079.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(22134079,RESET_EVENT+0x57a0000,0,0)
end
-- 判断是否为反转过的这张卡
function c22134079.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(22134079)~=0
end
-- 过滤函数：判断是否为「王家长眠之谷」卡组且能加入手牌
function c22134079.filter(c)
	return c:IsSetCard(0x91) and c:IsAbleToHand()
end
-- 效果原文内容
function c22134079.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22134079.filter(chkc) end
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingTarget(c22134079.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,c22134079.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用
function c22134079.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
