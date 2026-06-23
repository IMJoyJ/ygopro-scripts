--エターナル・ドレッド
-- 效果：
-- 「幽狱之时计塔」放置2个时计指示物。
function c35787450.initial_effect(c)
	-- 记录该卡与「幽狱之时计塔」的关联
	aux.AddCodeList(c,75041269)
	-- 「幽狱之时计塔」放置2个时计指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35787450.addtg)
	e1:SetOperation(c35787450.addc)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上的表侧表示的「幽狱之时计塔」是否可以放置2个时计指示物
function c35787450.filter(c)
	return c:IsFaceup() and c:IsCode(75041269) and c:IsCanAddCounter(0x1b,2)
end
-- 效果的发动时点处理函数，检查场上是否存在满足条件的「幽狱之时计塔」
function c35787450.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的「幽狱之时计塔」
	if chk==0 then return Duel.IsExistingMatchingCard(c35787450.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
end
-- 效果的发动处理函数，将满足条件的「幽狱之时计塔」上放置2个时计指示物
function c35787450.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的「幽狱之时计塔」
	local g=Duel.GetMatchingGroup(c35787450.filter,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1b,2)
		tc=g:GetNext()
	end
end
