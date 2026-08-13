--魔界発現世行きバス
-- 效果：
-- 这张卡被送去墓地时，选择「由魔界到现世的巴士」以外的自己或者对方的墓地1只怪兽回到持有者卡组。
function c52823314.initial_effect(c)
	-- 这张卡被送去墓地时，选择「由魔界到现世的巴士」以外的自己或者对方的墓地1只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52823314,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c52823314.target)
	e1:SetOperation(c52823314.operation)
	c:RegisterEffect(e1)
end
-- 筛选墓地中除卡号52823314（「由魔界到现世的巴士」）外、满足怪兽卡且能返回卡组的卡。
function c52823314.filter(c)
	return not c:IsCode(52823314) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 目标处理：若指定chkc则校验其在墓地且符合filter；chk==0时直接返回true（必发效果无需发动条件）；然后提示选择，从双方墓地选1只符合条件的怪兽作为对象，并设置将对象返回卡组的操作信息。
function c52823314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c52823314.filter(chkc) end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示「请选择要返回卡组的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己和对方墓地中选出1张满足filter条件的怪兽卡作为效果对象（取对象），Duel.SelectTarget会自动将选中的卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52823314.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息：本效果将选中的对象返回持有者卡组（CATEGORY_TODECK），数量为选择卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：取得对象卡，若对象仍与效果关联，则将其返回持有者卡组（以效果原因送去卡组并洗牌）。
function c52823314.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（本效果只选1张，因此即该卡；若对象已离场则返回nil）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者卡组并洗牌（SEQ_DECKSHUFFLE），移动原因记为效果（REASON_EFFECT）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
