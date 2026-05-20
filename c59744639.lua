--イタクァの暴風
-- 效果：
-- ①：对方场上的全部表侧表示怪兽的表示形式变更。
function c59744639.initial_effect(c)
	-- ①：对方场上的全部表侧表示怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetTarget(c59744639.target)
	e1:SetOperation(c59744639.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选表侧表示且可以改变表示形式的怪兽
function c59744639.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果发动的目标检查与操作信息设置
function c59744639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59744639.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足过滤条件的怪兽组
	local sg=Duel.GetMatchingGroup(c59744639.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息为改变该怪兽组的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行：获取对方场上满足条件的怪兽并变更其表示形式
function c59744639.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有满足过滤条件的怪兽组
	local sg=Duel.GetMatchingGroup(c59744639.filter,tp,0,LOCATION_MZONE,nil)
	-- 将目标怪兽组的表示形式变更（表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示）
	Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
