--XXクルージョン
-- 效果：
-- ①：对方把手卡的怪兽的效果发动时才能发动。那个发动无效。有对方手卡的场合，再让对方选1张手卡丢弃。
function c31213049.initial_effect(c)
	-- 效果原文内容：①：对方把手卡的怪兽的效果发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c31213049.condition)
	e1:SetTarget(c31213049.target)
	e1:SetOperation(c31213049.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断连锁是否满足发动条件，包括发动玩家为对方、发动位置在手卡、发动的是怪兽效果且该连锁可被无效。
function c31213049.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的发动位置信息。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 规则层面作用：判断发动玩家是否为对方、发动位置是否为手卡、发动效果是否为怪兽类型、以及该连锁是否可以被无效。
	return ep==1-tp and loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 效果原文内容：那个发动无效。有对方手卡的场合，再让对方选1张手卡丢弃。
function c31213049.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁操作信息，标记将使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 规则层面作用：判断对方手卡是否存在，用于决定是否触发后续丢弃手卡效果。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 规则层面作用：设置连锁操作信息，标记将使对方丢弃1张手卡。
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	end
end
-- 规则层面作用：执行效果处理，先使连锁无效，再判断对方是否有手卡，若有则令其丢弃1张手卡。
function c31213049.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断连锁是否成功无效且对方手卡存在，决定是否继续执行丢弃手卡效果。
	if Duel.NegateActivation(ev) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 规则层面作用：中断当前效果处理流程，防止错时点。
		Duel.BreakEffect()
		-- 规则层面作用：令对方丢弃1张手卡，丢弃原因为效果或丢弃。
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
