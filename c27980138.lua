--ガルドスの羽根ペン
-- 效果：
-- 选择自己墓地存在的2只风属性怪兽回到卡组，选择场上存在的1张卡回到持有者手卡。
function c27980138.initial_effect(c)
	-- 效果原文：选择自己墓地存在的2只风属性怪兽回到卡组，选择场上存在的1张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27980138.target)
	e1:SetOperation(c27980138.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的风属性怪兽（必须是怪兽且可以送去卡组）
function c27980138.filter1(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 检索满足条件的可以送去手牌的卡（无特殊条件）
function c27980138.filter2(c)
	return c:IsAbleToHand()
end
-- 判断是否满足发动条件：墓地存在2只风属性怪兽且场上存在1张可送入手牌的卡
function c27980138.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断墓地是否存在2只满足filter1条件的卡
	if chk==0 then return Duel.IsExistingTarget(c27980138.filter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 判断场上是否存在1张满足filter2条件的卡
		and Duel.IsExistingTarget(c27980138.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2只满足filter1条件的墓地怪兽作为目标
	local g1=Duel.SelectTarget(tp,c27980138.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1张满足filter2条件的场上卡作为目标
	local g2=Duel.SelectTarget(tp,c27980138.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将g1中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 设置操作信息：将g2中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 效果处理函数：执行将卡送回卡组和手牌的操作
function c27980138.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中送回卡组的卡组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取操作信息中送回手牌的卡组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		-- 将g1中的卡以洗牌方式送回卡组
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if g2:GetFirst():IsRelateToEffect(e) then
			-- 将g2中的卡送回手牌
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
		end
	end
end
