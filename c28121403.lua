--大成仏
-- 效果：
-- 破坏场上所有装备了装备卡的怪兽。
function c28121403.initial_effect(c)
	-- 破坏场上所有装备了装备卡的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_EQUIP)
	e1:SetTarget(c28121403.target)
	e1:SetOperation(c28121403.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选出场上装备有装备卡的怪兽（装备卡数量大于0）。
function c28121403.filter(c)
	return c:GetEquipCount()>0
end
-- 效果发动时的目标处理：发动时检查是否存在符合条件的怪兽，并收集所有符合条件的怪兽，将破坏它们的信息记录到连锁处理中。
function c28121403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：在效果发动时（chk==0）检查场上是否存在至少1只装备了装备卡的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有装备了装备卡的怪兽的集合，作为破坏效果的对象候选。
	local g=Duel.GetMatchingGroup(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁处理的操作信息设定为破坏g中的所有怪兽，数量为g的怪兽数，用于时点检测和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：获取当前场上所有装备了装备卡的怪兽，并将其全部破坏。
function c28121403.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段重新获取场上所有装备了装备卡的怪兽集合（确保根据实际场上状态处理）。
	local g=Duel.GetMatchingGroup(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏集合g中的所有怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
