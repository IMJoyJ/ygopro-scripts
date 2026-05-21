--地縛旋風
-- 效果：
-- 自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
function c96907086.initial_effect(c)
	-- 自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c96907086.condition)
	e1:SetTarget(c96907086.target)
	e1:SetOperation(c96907086.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名含有「地缚神」的卡
function c96907086.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1021)
end
-- 发动条件：检查自己场上是否存在表侧表示的「地缚神」怪兽
function c96907086.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区是否存在至少1张表侧表示的「地缚神」怪兽
	return Duel.IsExistingMatchingCard(c96907086.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c96907086.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标选择与处理：检查对方场上是否存在魔法·陷阱卡，并设置破坏的操作信息
function c96907086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方场上是否存在至少1张魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96907086.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法和陷阱卡
	local g=Duel.GetMatchingGroup(c96907086.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏对方场上的所有魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对方场上所有的魔法·陷阱卡
function c96907086.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法和陷阱卡
	local g=Duel.GetMatchingGroup(c96907086.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的卡片组，原因为效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
