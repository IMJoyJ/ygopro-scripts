--エターナル・ドレッド
-- 效果：
-- 「幽狱之时计塔」放置2个时计指示物。
function c35787450.initial_effect(c)
	-- 记录这张卡的卡上记载着「幽狱之时计塔」（卡号75041269）的卡名，使本卡被视为记载该卡名的卡。
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
c35787450.mentioned_counter={
	[0x1b]=true,
}
-- 过滤函数：选出表侧表示且卡名为「幽狱之时计塔」、并且可以再放置2个时计指示物的卡。
function c35787450.filter(c)
	return c:IsFaceup() and c:IsCode(75041269) and c:IsCanAddCounter(0x1b,2)
end
-- 目标函数：确认双方场地区是否存在满足过滤条件的卡，以此判断本卡能否发动。
function c35787450.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查双方场地区是否至少存在1张表侧表示且可放置2个时计指示物的「幽狱之时计塔」。
	if chk==0 then return Duel.IsExistingMatchingCard(c35787450.filter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
end
-- 操作函数：取得双方场地区所有满足条件的卡，逐一为它们放置2个时计指示物。
function c35787450.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场地区所有表侧表示且可放置2个时计指示物的「幽狱之时计塔」组成卡组。
	local g=Duel.GetMatchingGroup(c35787450.filter,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1b,2)
		tc=g:GetNext()
	end
end
