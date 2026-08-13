--つり天井
-- 效果：
-- 全场上的怪兽4只以上存在的场合才能发动。表侧表示的怪兽全部破坏。
function c38411870.initial_effect(c)
	-- 全场上的怪兽4只以上存在的场合才能发动。表侧表示的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c38411870.condition)
	e1:SetTarget(c38411870.target)
	e1:SetOperation(c38411870.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检测双方场上怪兽区存在的怪兽总数是否不少于4只，满足“全场上的怪兽4只以上存在的场合才能发动”的条件。
function c38411870.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前全场怪兽区（己方主要怪兽区+对方主要怪兽区）的怪兽总数是否大于等于4，是则允许发动。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>=4
end
-- 过滤器：选择场上表侧表示的怪兽，作为后续“表侧表示的怪兽全部破坏”的破坏对象。
function c38411870.filter(c)
	return c:IsFaceup()
end
-- 目标处理：进行发动合法性检查（chk==0）时确认场上至少存在1只表侧怪兽；若成立则收集场上全部表侧怪兽，并设置本次操作将破坏这些怪兽（破坏分类）。
function c38411870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认场上是否存在至少1只表侧表示的怪兽，确保效果处理时能有破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有表侧表示的怪兽，作为本次效果预定破坏的全体对象集合。
	local sg=Duel.GetMatchingGroup(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：宣告本次效果将破坏上述全部表侧怪兽，破坏数量为集合内卡数（用于触发时点及效果互动判定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：重新获取场上当前所有表侧表示的怪兽，并将其全部破坏，实现“表侧表示的怪兽全部破坏”。
function c38411870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上所有表侧表示的怪兽（以此时的场上状态为准，因该效果不取对象）。
	local sg=Duel.GetMatchingGroup(c38411870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将集合中的全部表侧表示怪兽破坏（送入墓地）。
	Duel.Destroy(sg,REASON_EFFECT)
end
