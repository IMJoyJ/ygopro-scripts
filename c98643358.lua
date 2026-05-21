--ダイヤモンド・ダスト
-- 效果：
-- 场上的水属性怪兽全部破坏。那之后，给与对方基本分这个效果破坏送去墓地的水属性怪兽数量×500的数值的伤害。
function c98643358.initial_effect(c)
	-- 场上的水属性怪兽全部破坏。那之后，给与对方基本分这个效果破坏送去墓地的水属性怪兽数量×500的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c98643358.target)
	e1:SetOperation(c98643358.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为场上表侧表示的水属性怪兽
function c98643358.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动时的目标选择与处理：检查场上是否存在水属性怪兽，并设置破坏与伤害的操作信息
function c98643358.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查双方场上是否存在至少1只表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98643358.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有表侧表示的水属性怪兽组
	local g=Duel.GetMatchingGroup(c98643358.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，预估给与对方玩家的伤害数值（数量×500）
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 过滤函数：检查卡片是否在墓地且为水属性
function c98643358.ctfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果处理：破坏场上的水属性怪兽，并根据送去墓地的数量给与对方伤害
function c98643358.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有表侧表示的水属性怪兽组
	local g=Duel.GetMatchingGroup(c98643358.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏这些怪兽，并检查是否有怪兽被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 在实际被操作的卡片组中，过滤并统计因该效果破坏且送去墓地的水属性怪兽数量
		local ct=Duel.GetOperatedGroup():FilterCount(c98643358.ctfilter,nil)
		if ct>0 then
			-- 中断当前效果处理，使后续的伤害处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 给与对方玩家对应的伤害（送墓数量×500）
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
end
