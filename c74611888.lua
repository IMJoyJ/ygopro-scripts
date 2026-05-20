--手のひら返し
-- 效果：
-- 和原本等级不同等级的怪兽在场上表侧表示存在的场合才能发动。场上的怪兽全部变成里侧守备表示。
function c74611888.initial_effect(c)
	-- 和原本等级不同等级的怪兽在场上表侧表示存在的场合才能发动。场上的怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c74611888.condition)
	e1:SetTarget(c74611888.target)
	e1:SetOperation(c74611888.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤场上表侧表示、等级与原本等级不同且具有等级的怪兽
function c74611888.cfilter(c)
	return c:IsFaceup() and not c:IsLevel(c:GetOriginalLevel()) and c:IsLevelAbove(1)
end
-- 发动条件：检查场上是否存在满足条件的怪兽（表侧表示且等级与原本等级不同）
function c74611888.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示且当前等级与原本等级不同的怪兽
	return Duel.IsExistingMatchingCard(c74611888.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数：过滤场上表侧表示且可以转成里侧表示的怪兽
function c74611888.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果的目标：确认场上存在可转为里侧表示的怪兽，并设置改变表示形式的操作信息
function c74611888.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查场上是否存在至少1只可以转成里侧表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74611888.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有可以转成里侧表示的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c74611888.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：表示此效果会改变上述怪兽组中所有怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果的处理：将场上所有可以转为里侧表示的表侧表示怪兽全部变成里侧守备表示
function c74611888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有可以转成里侧表示的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c74611888.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽全部改变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
