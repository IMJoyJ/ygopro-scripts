--剣現する武神
-- 效果：
-- 可以从以下效果选择1个发动。
-- ●选择自己墓地1只名字带有「武神」的怪兽加入手卡。
-- ●选择从游戏中除外的1只自己的名字带有「武神」的怪兽回到墓地。
function c30338466.initial_effect(c)
	-- 可以从以下效果选择1个发动。●选择自己墓地1只名字带有「武神」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30338466,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30338466.target)
	e1:SetOperation(c30338466.activate)
	c:RegisterEffect(e1)
	-- 可以从以下效果选择1个发动。●选择从游戏中除外的1只自己的名字带有「武神」的怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30338466,1))  --"除外回到墓地"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c30338466.target2)
	e2:SetOperation(c30338466.activate2)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡名含有「武神」的怪兽，且该怪兽能够加入手卡。
function c30338466.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 第一个效果的发动条件与取对象处理：确认自己墓地存在至少1只符合条件的「武神」怪兽后，选择其中1只作为效果对象，并设定为回手牌的操作信息。
function c30338466.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30338466.filter(chkc) end
	-- 在发动合法性检查时，确认自己墓地存在至少1张满足筛选条件的「武神」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30338466.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家提示正在选择要加入手牌的卡，显示对应选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让操作玩家从自己墓地的满足条件卡中选取1张作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30338466.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本连锁预定将1张对象卡加入手牌（CATEGORY_TOHAND），供相关卡进行效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果结算：将对象怪兽加入其持有者的手卡（因效果而回到手牌），并让对方玩家确认该卡。
function c30338466.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个效果对象卡（即先前选择的墓地「武神」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把对象卡送去持有者的手卡，移动原因为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将回收到手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 筛选出除外区的表侧表示且卡名含有「武神」的怪兽卡。
function c30338466.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
end
-- 第二个效果的发动条件与取对象处理：确认自己除外区存在至少1只符合条件的「武神」怪兽后，选择其中1只作为效果对象（用于送回墓地）。
function c30338466.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c30338466.filter2(chkc) end
	-- 在发动合法性检查时，确认自己除外区存在至少1张满足条件的表侧「武神」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30338466.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向操作玩家提示正在选择要送去墓地的卡，显示对应选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让操作玩家从自己除外区满足条件的卡中选取1张作为效果对象，并自动登记为当前连锁的对象。
	Duel.SelectTarget(tp,c30338466.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
end
-- 效果结算：将对象怪兽从除外区送回墓地，原因为效果处理并附带回到墓地（REASON_RETURN）。
function c30338466.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个效果对象卡（即先前选择的除外区「武神」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地，原因为效果处理并附加回到墓地（REASON_RETURN）。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
