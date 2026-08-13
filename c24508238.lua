--D.D.クロウ
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡丢弃去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。
function c24508238.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24508238,0))  --"对方墓地1张卡除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,0x11e0)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c24508238.cost)
	e1:SetTarget(c24508238.target)
	e1:SetOperation(c24508238.operation)
	c:RegisterEffect(e1)
end
-- cost函数：检查这张卡是否能作为cost丢弃去墓地，满足条件时执行丢弃自身作为发动代价。
function c24508238.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 以“cost+丢弃”的理由把这张卡从手卡送去墓地，支付发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- target函数：选择对方墓地1张可除外的卡作为对象，并设置除外相关的操作信息。
function c24508238.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查当前是否存在至少1张对方墓地的卡可以被除外，作为效果能否发动的条件之一。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向操作者弹出“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 在对方墓地中选择1张可除外的卡作为效果对象，并自动建立该卡与当前效果的关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的处理信息：本次操作涉及除外1张卡，对象位于对方墓地，控制者为对方。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- operation函数：效果处理时取得对象卡，若对象仍与效果关联则将其除外。
function c24508238.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以表侧表示除外，完成“那张卡除外”的效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
