--ギャクタン
-- 效果：
-- ①：陷阱卡发动时才能发动。那个发动无效，那张卡回到卡组。
function c34507039.initial_effect(c)
	-- 效果原文内容：①：陷阱卡发动时才能发动。那个发动无效，那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34507039.condition)
	e1:SetTarget(c34507039.target)
	e1:SetOperation(c34507039.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否为陷阱卡发动且可无效
function c34507039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：确认发动的是陷阱卡且为发动类型，同时该连锁可被无效
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置连锁处理信息，包括使发动无效和将卡送回卡组
function c34507039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置将卡送回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 效果作用：执行效果处理，使发动无效并送回卡组
function c34507039.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 效果作用：判断是否成功使发动无效且原卡仍在场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 效果作用：将卡以洗牌方式送回卡组
		Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
