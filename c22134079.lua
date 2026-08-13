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
	-- 反转过的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c22134079.flipop)
	c:RegisterEffect(e2)
	-- 此外，反转过的这张卡被送去墓地的场合，可以选择自己墓地1张名字带有「王家长眠之谷」的卡加入手卡。
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
	-- 这张卡的效果不会被「王家长眠之谷」的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e4)
end
-- 第一个效果发动时的取对象处理：从对方墓地选择1张可返回卡组的卡作为对象，并登记返回卡组的操作信息。
function c22134079.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 发动合法性检查：确认对方墓地存在至少1张能被选择且能返回卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向操作者显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让操作者从对方墓地选择1张可返回卡组的卡，并将其登记为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记操作信息：本连锁将把1张对象卡返回卡组，供后续处理与检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 第一个效果处理：将仍与效果关联的对象卡返回持有者卡组最下面。
function c22134079.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象卡送回其持有者卡组的最下面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 翻转时给这张卡注册“已反转”标记，用于标识它是“反转过的这张卡”，该标记会保持到离场等重置时。
function c22134079.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(22134079,RESET_EVENT+0x57a0000,0,0)
end
-- 第三个效果的发动条件：确认这张卡带有“已反转”标记，即它确实是反转过的这张卡。
function c22134079.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(22134079)~=0
end
-- 检索/选择过滤：判断卡是否为自己墓地中名字带有「王家长眠之谷」且能够加入手卡的卡。
function c22134079.filter(c)
	return c:IsSetCard(0x91) and c:IsAbleToHand()
end
-- 第三个效果发动时的取对象处理：从自己墓地选择1张满足条件的名字带有「王家长眠之谷」的卡作为对象，并登记加入手卡的操作信息。
function c22134079.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22134079.filter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张能够被选择且满足条件的卡。
	if chk==0 then return Duel.IsExistingTarget(c22134079.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作者从自己墓地选择1张符合条件的卡，并将其登记为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c22134079.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本连锁将把1张对象卡加入手牌，供后续处理与检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 第三个效果处理：将仍与效果关联的对象卡加入其持有者的手牌，并向对方展示该卡。
function c22134079.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
