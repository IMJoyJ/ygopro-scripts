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
-- 过滤函数，用于判断卡片是否为装备卡类型
function c20727787.filter(c)
	return c:IsType(TYPE_EQUIP)
end
-- 效果发动时的处理函数，用于确认是否满足发动条件并设置破坏对象
function c20727787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在至少一张装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 获取场上所有装备卡作为破坏目标
	local g=Duel.GetMatchingGroup(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,c)
	-- 设置连锁操作信息，表明此效果会破坏装备卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的实际处理函数，执行装备卡的破坏
function c20727787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有装备卡作为破坏目标，排除自身
	local g=Duel.GetMatchingGroup(c20727787.filter,tp,LOCATION_SZONE,LOCATION_SZONE,aux.ExceptThisCard(e))
	-- 将目标装备卡因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
