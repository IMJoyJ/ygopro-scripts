--カオス・エンド
-- 效果：
-- 当自己的卡有7张以上被除外时这张卡才能发动。破坏场上存在的所有怪兽卡。
function c61044390.initial_effect(c)
	-- 当自己的卡有7张以上被除外时这张卡才能发动。破坏场上存在的所有怪兽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c61044390.condition)
	e1:SetTarget(c61044390.target)
	e1:SetOperation(c61044390.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：判定自己除外区卡牌数量是否达到7张以上。
function c61044390.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己除外区的卡牌数量并判断是否大于等于7，作为发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)>=7
end
-- 定义效果发动时的目标检测与操作信息设置函数：确认场上存在怪兽，并预登记破坏全部怪兽的操作信息。
function c61044390.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：场上至少存在1只怪兽才能发动（因为要破坏怪兽）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有怪兽作为对象（不取对象，但用于设置操作信息）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏，目标为场上所有怪兽，数量为怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：效果处理时获取场上所有怪兽并全部破坏。
function c61044390.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时取得场上所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将那些怪兽全部破坏（由于卡的效果）。
	Duel.Destroy(g,REASON_EFFECT)
end
