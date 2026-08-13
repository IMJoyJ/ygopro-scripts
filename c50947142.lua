--くず鉄のシグナル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：需要同调怪兽作为素材的同调怪兽在自己场上存在，对方把怪兽的效果发动时才能发动。那个发动无效。发动后这张卡不送去墓地，直接盖放。
function c50947142.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：需要同调怪兽作为素材的同调怪兽在自己场上存在，对方把怪兽的效果发动时才能发动。那个发动无效。发动后这张卡不送去墓地，直接盖放。
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
-- 定义筛选函数：用于检查场上是否存在“需要同调怪兽作为素材的同调怪兽”，要求该怪兽为表侧表示。
function c50947142.filter(c)
	-- 判定怪兽同时满足：是同调怪兽、卡面素材记载为同调怪兽、且表侧表示。
	return c:IsType(TYPE_SYNCHRO) and aux.IsMaterialListType(c,TYPE_SYNCHRO) and c:IsFaceup()
end
-- 发动条件判定：自己场上有满足条件的同调怪兽存在；对方发动的是怪兽效果；该效果发动可被无效；且发动者为对方。
function c50947142.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足filter条件的表侧同调怪兽。
	return Duel.IsExistingMatchingCard(c50947142.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 确认连锁上的效果是怪兽效果的发动、该发动可以被无效、且发动者为对方。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 发动时合法判定（无额外条件），并设置操作信息：本次无效对象为对方发动的怪兽效果。
function c50947142.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本连锁的操作信息：类别为无效发动，对象是当前连锁中对方发动的怪兽效果，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：无效对方怪兽效果的发动；随后若此卡仍与效果关联且可以被盖放，则中断效果处理，取消此卡的送墓确定状态，将其里侧盖放，并触发放置魔法陷阱的时点。
function c50947142.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方那个怪兽效果的发动无效。
	Duel.NegateActivation(ev)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果处理，使后续的盖放作为独立处理，避免错失时点。
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将此卡变为里侧守备表示，即直接盖放在场上。
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 以本卡为对象触发EVENT_SSET时点，用于联动其他检测魔法陷阱盖放的效果。
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
