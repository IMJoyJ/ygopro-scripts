--武装解除
-- 效果：
-- 将场上的装备卡全部破坏。
function c20727787.initial_effect(c)
	-- 将场上的装备卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_EQUIP)
	e1:SetTarget(c20727787.target)
	e1:SetOperation(c20727787.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上满足条件的卡片：仅选择装备魔法卡（TYPE_EQUIP）。
function c20727787.filter(c)
	return c:IsType(TYPE_EQUIP)
end
-- 发动时的目标处理：检查场上是否存在装备卡（自身除外），并预设定破坏场上所有装备卡的操作信息。
function c20727787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件判定：己方或对方场上存在装备魔法卡（除自身以外）时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 获取双方场上所有装备魔法卡（不包括自身）的集合，供操作信息统计数量。
	local g=Duel.GetMatchingGroup(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,c)
	-- 设置操作信息：要破坏的是上述装备卡集合及其数量，以此标记该效果为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取双方场上的全部装备魔法卡（自身除外），并全部破坏。
function c20727787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新检索双方场上的所有装备魔法卡，并排除效果发动的这张卡自身。
	local g=Duel.GetMatchingGroup(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,aux.ExceptThisCard(e))
	-- 将被选中的装备魔法卡全部破坏，破坏原因为效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
