--転生の予言
-- 效果：
-- ①：以双方墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。
function c46652477.initial_effect(c)
	-- ①：以双方墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46652477.target)
	e1:SetOperation(c46652477.activate)
	c:RegisterEffect(e1)
end
-- 定义发动时的取对象处理函数：在发动时确认是否存在合法对象，并让玩家选择双方墓地合计2张卡作为对象，同时设置回卡组的操作信息。
function c46652477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动前检查（chk==0）时，确认双方墓地是否存在至少2张能够返回卡组的卡，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	-- 提示当前玩家从墓地中选择要返回卡组的卡，显示“请选择要返回卡组的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方墓地中选择2张能够返回卡组的卡作为效果对象（取对象处理）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	-- 设置当前连锁的回卡组操作信息：已确定将有2张卡返回卡组，对象为已选择的g。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 定义效果处理时的函数：取得连锁发动时选择的对象，过滤出仍与该效果相关的卡，并将它们返回持有者卡组后洗牌。
function c46652477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组（即发动时选择的2张墓地卡片）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后仍相关的卡片送去持有者卡组并洗牌，处理原因为效果。这些卡回到持有者卡组。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
