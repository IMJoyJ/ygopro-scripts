--バスター・スラッシュ
-- 效果：
-- 自己场上有名字带有「/爆裂体」的怪兽表侧表示存在的场合才能发动。场上表侧表示存在的怪兽全部破坏。
function c40012727.initial_effect(c)
	-- 效果原文：自己场上有名字带有「/爆裂体」的怪兽表侧表示存在的场合才能发动。场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c40012727.condition)
	e1:SetTarget(c40012727.target)
	e1:SetOperation(c40012727.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在表侧表示的「/爆裂体」怪兽
function c40012727.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- 效果作用：判断发动条件是否满足，即自己场上是否存在名字带有「/爆裂体」的表侧表示怪兽
function c40012727.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在至少1张名字带有「/爆裂体」的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c40012727.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤场上所有表侧表示的怪兽
function c40012727.filter(c)
	return c:IsFaceup()
end
-- 效果作用：设置连锁处理的目标为场上所有表侧表示的怪兽，并设置破坏分类
function c40012727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即自己场上是否存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取场上所有表侧表示的怪兽组成Group
	local dg=Duel.GetMatchingGroup(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 效果作用：设置当前连锁处理的破坏对象为场上所有表侧表示的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果作用：执行破坏效果，将场上所有表侧表示的怪兽破坏
function c40012727.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上所有表侧表示的怪兽组成Group
	local dg=Duel.GetMatchingGroup(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 效果作用：将指定的怪兽组以效果原因进行破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
