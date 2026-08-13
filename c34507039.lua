--ギャクタン
-- 效果：
-- ①：陷阱卡发动时才能发动。那个发动无效，那张卡回到卡组。
function c34507039.initial_effect(c)
	-- ①：陷阱卡发动时才能发动。那个发动无效，那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34507039.condition)
	e1:SetTarget(c34507039.target)
	e1:SetOperation(c34507039.activate)
	c:RegisterEffect(e1)
end
-- 该函数为效果的发动条件判断：只有当发动者为陷阱卡、且该陷阱卡是以“效果发动”类型（EFFECT_TYPE_ACTIVATE）发动、并且该连锁可以被无效时，效果才满足发动条件。
function c34507039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 同时判断三点：发动者是陷阱卡、发动类型为效果发动、且当前连锁可被无效。
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 该函数为发动时的目标选择与操作信息设定：在发动时直接允许（chk==0返回true），然后设定将使该连锁无效的操作信息；若那张陷阱卡仍与本次发动相关，则再设定将其送回卡组的操作信息。
function c34507039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：本次效果将使当前连锁上的那张卡（eg中的陷阱卡）的发动无效，对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设定操作信息：本次效果将把那张被无效的陷阱卡送回持有者卡组，对象数量为1。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 该函数为效果处理时的实际执行：取得被无效的陷阱卡，若发动无效成功且该卡仍与本次效果相关，则取消其送墓确定状态并将其弹回持有者卡组并洗牌。
function c34507039.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 判断条件：只有当对方的发动被成功无效，且那张陷阱卡仍与本次效果保持关联时，才继续执行回卡组处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 以效果原因将那张陷阱卡送回持有者卡组，并标记为需要洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
