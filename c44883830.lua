--死の合唱
-- 效果：
-- 自己场上有3只「死亡青蛙」表侧表示存在时才能发动。对方场上存在的卡全部破坏。
function c44883830.initial_effect(c)
	-- 对应效果原文：“自己场上有3只「死亡青蛙」表侧表示存在时才能发动。对方场上存在的卡全部破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44883830.condition)
	e1:SetTarget(c44883830.target)
	e1:SetOperation(c44883830.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：卡片为表侧表示且卡号是84451804（即「死亡青蛙」）。
function c44883830.cfilter(c)
	return c:IsFaceup() and c:IsCode(84451804)
end
-- 发动条件判定：检查己方主要怪兽区是否存在至少3张满足c44883830.cfilter条件的表侧表示「死亡青蛙」。
function c44883830.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 执行判定：在己方场上（LOCATION_MZONE）检索至少3张表侧表示的「死亡青蛙」。
	return Duel.IsExistingMatchingCard(c44883830.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 效果发动时的目标检测与操作信息设置：确认满足发动条件后，收集对方场上所有卡并预定对其进行破坏。
function c44883830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：若为首次检测（chk==0），则必须存在至少1张对方场上的卡才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有卡（不取对象，效果处理时确定破坏范围）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将获取到的对方场上全部卡标记为此次效果将要破坏的对象，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得对方场上全部卡并全部破坏。
function c44883830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方场上现存的所有卡（不取对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果破坏为原因，将获取到的对方场上所有卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
