--転生の予言
-- 效果：
-- ①：以双方墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。
function c46652477.initial_effect(c)
	-- 效果原文内容：①：以双方墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46652477.target)
	e1:SetOperation(c46652477.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检测是否满足发动条件并选择目标卡片
function c46652477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断场上是否存在至少2张可送入卡组的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	-- 效果作用：向玩家提示选择要送入卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择2张符合条件的卡片作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	-- 效果作用：设置连锁操作信息，指定将要处理的卡片数量和类型
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果原文内容：①：以双方墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。
function c46652477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中已选定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：将符合条件的卡片送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
