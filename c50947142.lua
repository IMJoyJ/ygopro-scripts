--くず鉄のシグナル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：需要同调怪兽作为素材的同调怪兽在自己场上存在，对方把怪兽的效果发动时才能发动。那个发动无效。发动后这张卡不送去墓地，直接盖放。
function c50947142.initial_effect(c)
	-- 创建效果，设置为发动时无效对方怪兽效果并盖放
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,50947142+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c50947142.condition)
	e1:SetTarget(c50947142.target)
	e1:SetOperation(c50947142.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示的同调怪兽作为素材的同调怪兽
function c50947142.filter(c)
	-- 同调怪兽且其融合素材类型包含同调怪兽，且表侧表示
	return c:IsType(TYPE_SYNCHRO) and aux.IsMaterialListType(c,TYPE_SYNCHRO) and c:IsFaceup()
end
-- 检查是否满足发动条件：己方场上有需要同调怪兽作为素材的同调怪兽，对方怪兽效果发动，且该发动可被无效
function c50947142.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上存在满足条件的同调怪兽
	return Duel.IsExistingMatchingCard(c50947142.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 对方怪兽效果发动且可被无效，且为对方发动
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 设置发动时的操作信息，确定要无效对方的怪兽效果
function c50947142.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效对方发动的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行效果，使对方效果无效并盖放此卡
function c50947142.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效
	Duel.NegateActivation(ev)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果处理，防止后续效果同时处理
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将此卡变为里侧表示（盖放）
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发放置魔陷时的时点
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
