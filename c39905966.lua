--リチュア・マーカー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，可以选择名字带有「遗式」的自己墓地存在的1张仪式怪兽或者仪式魔法卡加入手卡。
function c39905966.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，可以选择名字带有「遗式」的自己墓地存在的1张仪式怪兽或者仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39905966,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c39905966.tg)
	e1:SetOperation(c39905966.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出持有「遗式」字段、类型为仪式怪兽或仪式魔法卡，并且能够加入手卡的卡。
function c39905966.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 效果发动时的选择对象处理：若收到对象卡则校验其是否为合法对象；发动时确认自己墓地存在至少1张符合条件的卡，然后选择1张作为对象，并登记加入手牌的操作信息。
function c39905966.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39905966.filter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足条件的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39905966.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c39905966.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记连锁操作信息：本效果将要把选择的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象后，若对象仍与该效果关联，则将其加入手牌，并向对方玩家确认那张卡。
function c39905966.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该卡加入其持有者的手牌，加入原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认这张卡，以公开其返回手牌的事实。
		Duel.ConfirmCards(1-tp,tc)
	end
end
