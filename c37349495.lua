--ナチュル・エッグプラント
-- 效果：
-- 这张卡从场上送去墓地时，可以选择自己墓地存在的「自然茄子」以外的1只名字带有「自然」的怪兽加入手卡。
function c37349495.initial_effect(c)
	-- 诱发选发效果，满足条件时可以从墓地将名字带有「自然」的怪兽加入手牌
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
-- 这张卡从场上送去墓地时才能发动
function c37349495.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选墓地里名字带有「自然」的怪兽（不包括自己）
function c37349495.filter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and not c:IsCode(37349495) and c:IsAbleToHand()
end
-- 选择目标：从自己墓地选择1只符合条件的怪兽
function c37349495.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37349495.filter(chkc) end
	-- 检查是否有符合条件的怪兽可以作为目标
	if chk==0 then return Duel.IsExistingTarget(c37349495.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37349495.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，准备将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将选中的怪兽加入手牌并确认对方看到
function c37349495.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认看到被加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
