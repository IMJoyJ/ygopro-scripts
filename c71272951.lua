--オーバースペック
-- 效果：
-- 场上表侧表示存在的怪兽的攻击力比原本攻击力高的场合，那些怪兽全部破坏。
function c71272951.initial_effect(c)
	-- 场上表侧表示存在的怪兽的攻击力比原本攻击力高的场合，那些怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c71272951.target)
	e1:SetOperation(c71272951.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选场上表侧表示且当前攻击力大于原本攻击力的怪兽
function c71272951.filter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 效果发动的目标检测与操作信息设置
function c71272951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1只符合过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71272951.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有符合过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c71272951.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表明此效果的处理为破坏这些符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行破坏符合条件怪兽的操作
function c71272951.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取场上所有符合过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c71272951.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将获取到的怪兽全部因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
