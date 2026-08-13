--レアル・ジェネクス・ウルティマム
-- 效果：
-- ①：场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽回到卡组。
function c46572756.initial_effect(c)
	-- ①：场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地2只「次世代」怪兽为对象才能发动。那些怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46572756,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46572756.condition)
	e1:SetTarget(c46572756.target)
	e1:SetOperation(c46572756.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡被破坏送去墓地前是否位于场上且表侧表示，且破坏原因为破坏，以此作为效果触发条件。
function c46572756.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选自己墓地里持有「次世代」字段且能够返回卡组的怪兽。
function c46572756.filter(c)
	return c:IsSetCard(0x2) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择处理：从自己墓地选择2只满足条件的「次世代」怪兽作为对象，并设置返回卡组的操作信息。
function c46572756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46572756.filter(chkc) end
	-- 发动条件检查：确认自己墓地是否存在至少2只满足条件的「次世代」怪兽，以保证可以选取对象。
	if chk==0 then return Duel.IsExistingTarget(c46572756.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2只满足条件的「次世代」怪兽，并将它们登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c46572756.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：本次效果将把2张对象卡返回持有者卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理时的执行：取得连锁对象，过滤出仍与效果关联的卡，将它们返回持有者卡组并洗牌。
function c46572756.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的效果对象卡组，即发动时选择的2只墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 以效果原因（REASON_EFFECT）将仍关联的对象卡返回持有者卡组，并执行洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
