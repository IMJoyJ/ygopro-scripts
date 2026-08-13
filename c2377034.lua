--ネオフレムベル・ヘッジホッグ
-- 效果：
-- 这张卡被战斗破坏的场合，选择对方墓地存在的1张卡从游戏中除外。场上存在的这张卡被卡的效果破坏的场合，选择自己墓地存在的「新炎狱刺猬」以外的1只守备力200以下的炎属性怪兽加入手卡。
function c2377034.initial_effect(c)
	-- 这张卡被战斗破坏的场合，选择对方墓地存在的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2377034,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c2377034.rmtg)
	e1:SetOperation(c2377034.rmop)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被卡的效果破坏的场合，选择自己墓地存在的「新炎狱刺猬」以外的1只守备力200以下的炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2377034,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c2377034.thcon)
	e2:SetTarget(c2377034.thtg)
	e2:SetOperation(c2377034.thop)
	c:RegisterEffect(e2)
end
-- 第一个效果的发动时目标选择：从对方墓地选择1张可除外的卡作为效果对象，并设置除外处理信息。
function c2377034.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可以除外的卡，并设为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 将本次效果要除外的卡片信息登记为：对象g、数量g:GetCount()、对象持有者为对方、位置为墓地，供系统判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 第一个效果处理：若对象卡仍与效果关联，则将其表侧表示从游戏中除外。
function c2377034.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得第一个效果选择的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外（除外原因视为效果）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 第二个效果的发动条件：这张卡被卡的效果破坏而离场（离场原因包含效果破坏）。
function c2377034.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 第二个效果的检索筛选：自己墓地中守备力200以下、炎属性、卡名不是「新炎狱刺猬」、且可以加入手卡的怪兽。
function c2377034.filter(c)
	local def=c:GetDefense()
	return def>=0 and def<=200 and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(2377034) and c:IsAbleToHand()
end
-- 第二个效果的目标选择：从自己墓地选择1只满足筛选条件的怪兽作为对象，并设置加入手卡的处理信息。
function c2377034.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2377034.filter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只满足筛选条件的怪兽，并设为效果的对象。
	local g=Duel.SelectTarget(tp,c2377034.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果将所选卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 第二个效果的处理：将对象卡加入持有者手卡，并让对方确认加入手卡的卡。
function c2377034.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得第二个效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡（原因：效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对手确认被加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
