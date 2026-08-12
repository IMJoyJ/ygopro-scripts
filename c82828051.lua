--アースクエイク
-- 效果：
-- 场上存在的表侧表示怪兽全部变成守备表示。
function c82828051.initial_effect(c)
	-- 场上存在的表侧表示怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c82828051.target)
	e1:SetOperation(c82828051.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上表侧攻击表示且可以改变表示形式的怪兽
function c82828051.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果发动的目标确认与操作信息设置
function c82828051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只可以改变表示形式的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82828051.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有可以改变表示形式的表侧攻击表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(c82828051.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表示该效果将改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：获取符合条件的怪兽并将其全部变成表侧守备表示
function c82828051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有可以改变表示形式的表侧攻击表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(c82828051.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将目标怪兽全部改变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
