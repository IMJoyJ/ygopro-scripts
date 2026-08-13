--ガルドスの羽根ペン
-- 效果：
-- 选择自己墓地存在的2只风属性怪兽回到卡组，选择场上存在的1张卡回到持有者手卡。
function c27980138.initial_effect(c)
	-- 对应效果原文：选择自己墓地存在的2只风属性怪兽回到卡组，选择场上存在的1张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27980138.target)
	e1:SetOperation(c27980138.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足风属性、怪兽类型且可以返回卡组的卡。
function c27980138.filter1(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 筛选场上可以返回手卡的卡。
function c27980138.filter2(c)
	return c:IsAbleToHand()
end
-- 效果的目标选择函数：检查是否满足墓地2只风属性怪兽和场上1张可回手卡的条件，并让玩家选择相应对象。
function c27980138.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时检查自己墓地是否存在至少2只满足filter1的风属性怪兽，作为回卡组的对象。
	if chk==0 then return Duel.IsExistingTarget(c27980138.filter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查场上（双方）是否存在至少1张除本卡外满足filter2的卡，作为回持有者手卡的对象。
		and Duel.IsExistingTarget(c27980138.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要返回卡组的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择2只满足filter1的风属性怪兽，并将其设为效果对象。
	local g1=Duel.SelectTarget(tp,c27980138.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 向玩家显示“请选择要返回手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上（双方）1张除自身外满足filter2的卡，并将其设为效果对象。
	local g2=Duel.SelectTarget(tp,c27980138.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将g1中的2张怪兽卡返回卡组，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 设置操作信息：将g2中的1张卡返回持有者手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 效果处理函数：若墓地2只怪兽仍与效果相关，则将其送回卡组；随后若场上对象仍相关，则将其送回持有者手卡。
function c27980138.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出之前设置的回卡组操作信息，获得目标组g1。
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 取出之前设置的回手卡操作信息，获得目标组g2。
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		-- 以洗牌方式将g1中的怪兽返回持有者卡组，原因记为效果。
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if g2:GetFirst():IsRelateToEffect(e) then
			-- 将g2中的那张卡返回持有者手卡，原因记为效果。
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
		end
	end
end
