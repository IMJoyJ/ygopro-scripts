--おろかな転生
-- 效果：
-- 选择对方墓地存在的1张卡发动。选择的卡回到卡组。
function c88369727.initial_effect(c)
	-- 选择对方墓地存在的1张卡发动。选择的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c88369727.target)
	e1:SetOperation(c88369727.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与准备阶段，判断并选择对方墓地中可以回到卡组的卡作为对象
function c88369727.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 在发动阶段的检查时，判断对方墓地是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地中1张可以回到卡组的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息，表明此效果的操作分类为“送回卡组”，涉及卡片为选中的对象，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段，获取对象卡片并将其送回卡组并洗牌
function c88369727.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
