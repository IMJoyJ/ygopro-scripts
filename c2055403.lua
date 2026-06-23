--時空の落とし穴
-- 效果：
-- ①：对方从手卡·额外卡组把怪兽特殊召唤时才能发动。从手卡·额外卡组特殊召唤的那些怪兽回到持有者卡组。那之后，自己失去回去的怪兽数量×1000基本分。
function c2055403.initial_effect(c)
	-- ①：对方从手卡·额外卡组把怪兽特殊召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c2055403.target)
	e1:SetOperation(c2055403.activate)
	c:RegisterEffect(e1)
end
-- 筛选出由对方特殊召唤且位置在手卡或额外卡组的怪兽
function c2055403.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_HAND+LOCATION_EXTRA)
		and c:IsAbleToDeck() and c:IsLocation(LOCATION_MZONE)
end
-- 检查是否有满足条件的怪兽，若有则设置效果目标为这些怪兽
function c2055403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c2055403.filter,nil,tp)
	local ct=g:GetCount()
	if chk==0 then return ct>0 end
	-- 将连锁处理的对象设置为所有参与特殊召唤的怪兽
	Duel.SetTargetCard(eg)
	-- 设置效果操作信息为将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,ct,0,0)
end
-- 将满足条件的怪兽送回卡组并洗牌，然后根据送回的怪兽数量扣除基本分
function c2055403.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c2055403.filter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将怪兽以效果原因送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取实际被操作的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 扣除基本分，扣除值为送回卡组的怪兽数量乘以1000
			Duel.SetLP(tp,Duel.GetLP(tp)-ct*1000)
		end
	end
end
