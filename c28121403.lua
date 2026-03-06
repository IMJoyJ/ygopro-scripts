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
-- 过滤函数，用于判断怪兽是否装备有装备卡
function c28121403.filter(c)
	return c:GetEquipCount()>0
end
-- 效果的发动时点处理，检查场上是否存在装备了装备卡的怪兽，并设置破坏效果的操作信息
function c28121403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在至少1只装备了装备卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有装备了装备卡的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的发动处理函数，执行破坏效果
function c28121403.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有装备了装备卡的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c28121403.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将指定的怪兽组全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
