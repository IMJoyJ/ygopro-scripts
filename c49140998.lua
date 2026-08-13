--鳳凰神の羽根
-- 效果：
-- 丢弃1张手卡，选择自己墓地1张卡才能发动。选择的卡回到卡组最上面。
function c49140998.initial_effect(c)
	-- 丢弃1张手卡，选择自己墓地1张卡才能发动。选择的卡回到卡组最上面。
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
-- 代价处理：检查并执行丢弃1张手卡作为发动代价。
function c49140998.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中至少有1张可以丢弃的卡（不包括效果发动者自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手牌选择1张卡丢弃，丢弃原因标记为代价并丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标选择：选择自己墓地的1张可以返回卡组的卡作为效果对象，并登记操作信息。
function c49140998.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	-- 目标检查：确认自己墓地存在至少1张可以返回卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张可以返回卡组的卡作为效果对象。
	local sg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作信息：将选择的卡返回卡组，供连锁等相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- 效果处理：将选择的目标卡返回卡组最上面。
function c49140998.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时锁定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回卡组最顶端。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
