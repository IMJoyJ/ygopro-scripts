--進入禁止！No Entry！！
-- 效果：
-- 场上存在的攻击表示怪兽全部变成守备表示。
function c60306104.initial_effect(c)
	-- 场上存在的攻击表示怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c60306104.target)
	e1:SetOperation(c60306104.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上处于攻击表示且可以改变表示形式的怪兽
function c60306104.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果发动的准备阶段：检查是否存在符合条件的怪兽，并向系统申报将要改变表示形式的卡片信息
function c60306104.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查双方场上是否存在至少1只可以改变表示形式的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60306104.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有可以改变表示形式的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c60306104.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，向系统申报将要改变表示形式的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：获取当前场上符合条件的怪兽，并将其全部改变为守备表示
function c60306104.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有可以改变表示形式的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c60306104.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽的表示形式改变为守备表示（表侧攻击表示变成表侧守备表示，里侧攻击表示变成里侧守备表示）
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
end
