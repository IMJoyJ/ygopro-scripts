--魔力枯渇
-- 效果：
-- 将自己与对方场上存在的所有魔力指示物全部除去。
function c95451366.initial_effect(c)
	-- 将自己与对方场上存在的所有魔力指示物全部除去。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95451366.target)
	e1:SetOperation(c95451366.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与条件检查函数
function c95451366.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否至少存在1个可以因效果除去的魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT) end
end
-- 过滤场上表侧表示且放置有魔力指示物的卡片
function c95451366.filter(c)
	return c:IsFaceup() and c:GetCounter(0x1)~=0
end
-- 效果处理的核心逻辑，获取并除去双方场上所有的魔力指示物
function c95451366.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示且放置有魔力指示物的卡片
	local g=Duel.GetMatchingGroup(c95451366.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		local cc=tc:GetCounter(0x1)
		tc:RemoveCounter(tp,0x1,cc,REASON_EFFECT)
		tc=g:GetNext()
	end
end
