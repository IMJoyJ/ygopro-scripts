--エクシーズ・バースト
-- 效果：
-- 自己场上有6阶以上的超量怪兽存在的场合才能发动。对方场上盖放的卡全部破坏。
function c30600344.initial_effect(c)
	-- 自己场上有6阶以上的超量怪兽存在的场合才能发动。对方场上盖放的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c30600344.condition)
	e1:SetTarget(c30600344.target)
	e1:SetOperation(c30600344.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：该怪兽为表侧表示且阶级在6阶以上，用于判断是否存在满足发动条件的超量怪兽。
function c30600344.cfilter(c)
	return c:IsFaceup() and c:IsRankAbove(6)
end
-- 发动条件检查：确认自己场上存在至少1只表侧表示的6阶以上超量怪兽。
function c30600344.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己场上（主要怪兽区与额外怪兽区）检索是否存在至少1只表侧表示且阶级在6阶以上的超量怪兽。
	return Duel.IsExistingMatchingCard(c30600344.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：该卡为里侧表示，用于筛选对方场上盖放的卡。
function c30600344.filter(c)
	return c:IsFacedown()
end
-- 发动时的目标处理：确认对方场上有里侧表示的卡，获取对方场上所有里侧表示的卡，并设置效果处理时将破坏这些卡的操作信息。
function c30600344.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：在发动时必须确认对方场上存在至少1张里侧表示的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30600344.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得对方场上所有里侧表示的卡，作为准备破坏的集合。
	local g=Duel.GetMatchingGroup(c30600344.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置本次连锁的操作信息：将对方场上全部里侧表示的卡登记为将被破坏的对象，数量为这些卡的总数，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：实际执行破坏，重新获取对方场上所有里侧表示的卡并以效果原因将其全部破坏。
function c30600344.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次取得对方场上当前所有里侧表示的卡，避免使用发动前的过时数据。
	local g=Duel.GetMatchingGroup(c30600344.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果（REASON_EFFECT）为原因将取得的里侧表示卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
