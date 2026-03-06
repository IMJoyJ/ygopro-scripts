--D.D.クロウ
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡丢弃去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。
function c24508238.initial_effect(c)
	-- 效果原文：自己·对方回合，把这张卡从手卡丢弃去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。
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
-- 效果作用：支付将此卡从手卡丢弃到墓地的代价
function c24508238.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 效果作用：将此卡从手卡丢弃到墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果作用：选择对方墓地1张可除外的卡作为对象
function c24508238.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 效果作用：检查对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择对方墓地1张可除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 效果作用：设置连锁操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果作用：执行将选中的卡除外
function c24508238.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
