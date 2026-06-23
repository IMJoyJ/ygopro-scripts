--鳳凰神の羽根
-- 效果：
-- 丢弃1张手卡，选择自己墓地1张卡才能发动。选择的卡回到卡组最上面。
function c49140998.initial_effect(c)
	-- 创建效果，设置为魔陷发动，取对象，自由时点，需要支付丢弃手卡的代价，选择目标，发动时处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c49140998.cost)
	e1:SetTarget(c49140998.target)
	e1:SetOperation(c49140998.activate)
	c:RegisterEffect(e1)
end
-- 丢弃1张手卡，选择自己墓地1张卡才能发动。
function c49140998.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件的手卡数量
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 选择自己墓地1张卡才能发动。选择的卡回到卡组最上面。
function c49140998.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	-- 检查是否满足条件的墓地卡片数量
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标墓地的卡
	local sg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，确定将要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- 将选择的卡送回卡组最上面
function c49140998.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组顶端
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
