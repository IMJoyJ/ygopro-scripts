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
-- 过滤函数，返回满足条件的表侧表示的机械族怪兽
function c50074522.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果处理时，检索场上所有满足条件的怪兽并设置操作信息为破坏效果
function c50074522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c50074522.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏效果，并指定目标怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时，对满足条件的怪兽进行破坏处理
function c50074522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c50074522.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将目标怪兽组以效果原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
