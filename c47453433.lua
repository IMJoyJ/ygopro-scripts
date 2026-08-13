--振り出し
-- 效果：
-- 丢弃1张手卡。场上1只怪兽回到持有者卡组最上面。
function c47453433.initial_effect(c)
	-- 丢弃1张手卡。场上1只怪兽回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c47453433.cost)
	e1:SetTarget(c47453433.target)
	e1:SetOperation(c47453433.activate)
	c:RegisterEffect(e1)
end
-- 代价函数的整体逻辑：先检查能否丢弃手卡作为发动代价，再执行丢弃1张手卡的操作。
function c47453433.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己手牌中存在1张（除发动中的这张卡以外）可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 发动代价处理：从手牌选择并丢弃1张可以丢弃的卡，丢弃原因设置为代价+丢弃，此操作不进入连锁。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标选择函数整体：确认场上是否存在可回卡组的怪兽，提示玩家选择1只，将其设为效果对象，并登记回卡组的操作信息。
function c47453433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToDeck() end
	-- 对象合法性检查：确认双方怪兽区合计存在至少1只满足“可以回到卡组”的怪兽，且能够成为此效果的对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让发动玩家从双方怪兽区选择1只可回卡组的怪兽作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：将本次效果确定为“回卡组”类别，作用对象为已选怪兽，数量为1，供其他卡效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数整体：连锁处理时取出发动时选择的对象，若该对象仍与效果相关联，则将其返回持有者卡组最上面。
function c47453433.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一张对象卡，即发动时选择的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回其持有者卡组的最顶端，处理原因为效果送回。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
