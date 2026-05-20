--魔草 マンドラゴラ
-- 效果：
-- 反转：给场上表侧表示存在的可以放置魔力指示物的卡全部放置1个魔力指示物。
function c7802006.initial_effect(c)
	-- 反转：给场上表侧表示存在的可以放置魔力指示物的卡全部放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7802006,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c7802006.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且可以放置魔力指示物的卡片
function c7802006.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 效果处理：获取双方场上所有满足过滤条件的卡片，并循环为这些卡片各放置1个魔力指示物
function c7802006.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c7802006.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1,1)
		tc=g:GetNext()
	end
end
