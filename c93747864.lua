--砂漠の光
-- 效果：
-- 自己场上的所有怪兽全部变成表侧守备表示。
function c93747864.initial_effect(c)
	-- 自己场上的所有怪兽全部变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93747864.target)
	e1:SetOperation(c93747864.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：非表侧守备表示且可以改变表示形式的怪兽
function c93747864.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 效果发动的目标处理：检查是否存在可行怪兽并设置操作信息
function c93747864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93747864.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c93747864.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置当前连锁的操作信息为改变表示形式，对象为上述怪兽组
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将自己场上满足条件的怪兽全部变为表侧守备表示
function c93747864.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取自己场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c93747864.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将获取到的怪兽全部改变为表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
