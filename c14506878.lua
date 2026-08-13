--ダッカー
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1只4星怪兽为对象发动。那只怪兽加入手卡。
function c14506878.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1只4星怪兽为对象发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14506878,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c14506878.thtg)
	e1:SetOperation(c14506878.thop)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中等级为4且可以加入手卡的怪兽。
function c14506878.filter(c)
	return c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果发动时，检查对象卡是否合法，并从自己墓地的4星怪兽中选择1只作为效果对象，同时设置将对象加入手牌的操作信息。
function c14506878.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14506878.filter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要加入手牌的卡”的提示消息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的4星怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c14506878.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将当前效果的操作信息登记为“把对象加入手牌”，供连锁处理和效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时，取得效果对象，若该对象仍与效果关联，则将其加入持有者手牌。
function c14506878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
