--成仏
-- 效果：
-- 有装备卡装备的怪兽全部破坏。
function c95051344.initial_effect(c)
	-- 有装备卡装备的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95051344.target)
	e1:SetOperation(c95051344.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：当前装备有装备卡的怪兽
function c95051344.filter(c)
	return c:GetEquipCount()>0
end
-- 效果发动的目标检查与操作信息设置
function c95051344.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查双方场上是否存在至少1只装备有装备卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95051344.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有装备有装备卡的怪兽
	local g=Duel.GetMatchingGroup(c95051344.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数
function c95051344.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取双方场上所有装备有装备卡的怪兽
	local g=Duel.GetMatchingGroup(c95051344.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽全部因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
