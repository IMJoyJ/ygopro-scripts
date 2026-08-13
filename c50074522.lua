--電磁蚊
-- 效果：
-- 反转：场上表侧表示存在的机械族怪兽全部破坏。
function c50074522.initial_effect(c)
	-- 反转：场上表侧表示存在的机械族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c50074522.target)
	e1:SetOperation(c50074522.operation)
	c:RegisterEffect(e1)
end
-- 过滤出场上表侧表示且种族为机械族的怪兽，作为破坏对象候选。
function c50074522.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果发动时：不取对象，直接允许发动；随后检索场上所有表侧机械族怪兽，并将其破坏信息（分类、对象组、数量）登记到连锁处理中。
function c50074522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方主要怪兽区所有表侧表示且为机械族的怪兽，组成将要被破坏的卡组。
	local g=Duel.GetMatchingGroup(c50074522.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本次连锁的操作信息：声明为破坏效果，破坏对象为上述怪兽组，数量为组内卡片数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：重新检索场上所有表侧机械族怪兽并将其全部破坏（因为在处理时场上状态可能已变化，需以当前存在为准）。
function c50074522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，再次获取双方主要怪兽区所有表侧表示且为机械族的怪兽。
	local g=Duel.GetMatchingGroup(c50074522.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏这些怪兽，执行破坏处理。
	Duel.Destroy(g,REASON_EFFECT)
end
