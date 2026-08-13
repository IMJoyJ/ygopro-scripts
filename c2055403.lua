--時空の落とし穴
-- 效果：
-- ①：对方从手卡·额外卡组把怪兽特殊召唤时才能发动。从手卡·额外卡组特殊召唤的那些怪兽回到持有者卡组。那之后，自己失去回去的怪兽数量×1000基本分。
function c2055403.initial_effect(c)
	-- ①：对方从手卡·额外卡组把怪兽特殊召唤时才能发动。从手卡·额外卡组特殊召唤的那些怪兽回到持有者卡组。那之后，自己失去回去的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c2055403.target)
	e1:SetOperation(c2055403.activate)
	c:RegisterEffect(e1)
end
-- 筛选出由对方玩家从手牌或额外卡组特殊召唤、当前在怪兽区且可以返回卡组的怪兽。
function c2055403.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_HAND+LOCATION_EXTRA)
		and c:IsAbleToDeck() and c:IsLocation(LOCATION_MZONE)
end
-- 发动时判断：从特殊召唤成功的怪兽中筛出符合条件的部分，若数量大于0则允许发动；随后将这些怪兽登记为效果对象，并设置回卡组的操作信息。
function c2055403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c2055403.filter,nil,tp)
	local ct=g:GetCount()
	if chk==0 then return ct>0 end
	-- 将本次特殊召唤成功的所有怪兽组设为当前效果的对象（广义对象），用于后续确认其与效果的关联。
	Duel.SetTargetCard(eg)
	-- 设置效果处理中“回到卡组”的操作信息：对象为筛选出的怪兽组g、数量为ct，供其他卡片发动或判定时参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,ct,0,0)
end
-- 效果处理：重新筛选出仍与效果关联且符合条件的怪兽；若存在，则将其送回持有者卡组并洗牌，最后按实际返回的数量失去LP。
function c2055403.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c2055403.filter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽送回其持有者卡组，并标记为需要洗牌，回卡组的原因视为效果。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取刚才“回卡组”操作实际处理的卡片组，用于确定最终回去了多少只怪兽。
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			-- 中断当前效果，使后续LP伤害的结算与回卡组处理视为不同时进行，避免产生错误的时点。
			Duel.BreakEffect()
			-- 将当前玩家生命值减去ct×1000，即失去回去的怪兽数量×1000基本分。
			Duel.SetLP(tp,Duel.GetLP(tp)-ct*1000)
		end
	end
end
