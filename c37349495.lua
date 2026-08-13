--ナチュル・エッグプラント
-- 效果：
-- 这张卡从场上送去墓地时，可以选择自己墓地存在的「自然茄子」以外的1只名字带有「自然」的怪兽加入手卡。
function c37349495.initial_effect(c)
	-- 这张卡从场上送去墓地时，可以选择自己墓地存在的「自然茄子」以外的1只名字带有「自然」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37349495,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c37349495.thcon)
	e1:SetTarget(c37349495.thtg)
	e1:SetOperation(c37349495.thop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡从场上送去墓地，即这张卡此前所在位置是场上。
function c37349495.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：选择自己墓地存在的「自然茄子」以外的1只名字带有「自然」的怪兽，且该怪兽可以加入手卡。
function c37349495.filter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and not c:IsCode(37349495) and c:IsAbleToHand()
end
-- 发动目标：从自己墓地的「自然茄子」以外的名字带有「自然」的怪兽中选择1只作为对象，并设定将对象加入手牌的处理信息。
function c37349495.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37349495.filter(chkc) end
	-- 发动时判定：自己墓地是否存在至少1只符合条件的名字带有「自然」的怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c37349495.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：让操作者选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择对象：从自己墓地挑选1只符合条件的名字带有「自然」的怪兽作为本次效果的对象。
	local g=Duel.SelectTarget(tp,c37349495.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定操作信息：本次效果处理将把选择的对象加入手牌，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：若选择的对象仍与效果关联，则将其加入持有者手牌，并让对方确认该卡。
function c37349495.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
