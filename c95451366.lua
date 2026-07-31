--魔力枯渇
-- 效果：
-- 将自己与对方场上存在的所有魔力指示物全部除去。
function c95451366.initial_effect(c)
	-- 将自己与对方场上存在的所有魔力指示物全部去除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95451366.target)
	e1:SetOperation(c95451366.activate)
	c:RegisterEffect(e1)
end
c95451366.mentioned_counter={
	[0x1]=true,
}
-- 卡片发动准备：检查双方场上是否存在可以去除的魔力指示物
function c95451366.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方场上是否存在至少1个可被去除的魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT) end
end
-- 指示物目标过滤条件：双方场上放置有魔力指示物的表侧表示卡
function c95451366.filter(c)
	return c:IsFaceup() and c:GetCounter(0x1)~=0
end
-- 卡片发动处理：遍历双方场上所有放置魔力指示物的卡并全部去除
function c95451366.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有放置有魔力指示物的表侧表示卡
	local g=Duel.GetMatchingGroup(c95451366.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		local cc=tc:GetCounter(0x1)
		tc:RemoveCounter(tp,0x1,cc,REASON_EFFECT)
		tc=g:GetNext()
	end
end
