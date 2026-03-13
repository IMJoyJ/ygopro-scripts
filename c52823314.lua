--魔界発現世行きバス
-- 效果：
-- 这张卡被送去墓地时，选择「由魔界到现世的巴士」以外的自己或者对方的墓地1只怪兽回到持有者卡组。
function c52823314.initial_effect(c)
	-- 这张卡被送去墓地时，选择「由魔界到现世的巴士」以外的自己或者对方的墓地 1 只怪兽回到持有者卡组。
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
-- 定义过滤条件，排除同名卡且必须是能返回卡组的怪兽
function c52823314.filter(c)
	return not c:IsCode(52823314) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时选择墓地的符合条件的怪兽作为对象
function c52823314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c52823314.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示选择提示消息“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择墓地中 1 只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52823314.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息为返回卡组，记录对象卡和数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理时执行将选择的怪兽返回卡组的操作
function c52823314.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组顶端并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
