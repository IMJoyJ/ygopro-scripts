--魔力統轄
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「恩底弥翁」卡加入手卡。那之后，可以给自己场上的可以放置魔力指示物的卡尽可能放置最多有自己的场上·墓地的「魔力统辖」「魔力掌握」数量的魔力指示物。
function c38943357.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张「恩底弥翁」卡加入手卡。那之后，可以给自己场上的可以放置魔力指示物的卡尽可能放置最多有自己的场上·墓地的「魔力统辖」「魔力掌握」数量的魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38943357+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38943357.target)
	e1:SetOperation(c38943357.operation)
	c:RegisterEffect(e1)
end
c38943357.mentioned_counter={
	[0x1]=true,
}
-- 过滤函数：检查卡是否是「恩底弥翁」卡且可以加入手卡。
function c38943357.filter(c)
	return c:IsSetCard(0x12a) and c:IsAbleToHand()
end
-- 发动检测及操作信息设置函数：检测卡组中是否存在可以加入手卡的「恩底弥翁」卡，并设置加入手卡的操作信息。
function c38943357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己卡组中存在至少1张可以加入手卡的「恩底弥翁」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38943357.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次连锁处理将把卡组中1张卡加入手卡，用于其他卡的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 计数过滤函数：检查卡是否是「魔力统辖」或「魔力掌握」，且在场上的为表侧表示或在墓地中。
function c38943357.cfilter(c)
	return c:IsCode(38943357,75014062) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果处理函数：从卡组把1张「恩底弥翁」卡加入手卡并给对方确认，之后按自己场上·墓地的「魔力统辖」「魔力掌握」数量给自己场上可放置魔力指示物的卡放置魔力指示物。
function c38943357.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己提示选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组中选择1张满足条件的「恩底弥翁」卡。
	local g=Duel.SelectMatchingCard(tp,c38943357.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡以效果原因加入持有者手卡，并确认实际有卡被加入手卡。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 让对方玩家确认被加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 统计自己场上·墓地中「魔力统辖」「魔力掌握」的数量，作为可放置的魔力指示物的最大数量。
		local ct=Duel.GetMatchingGroupCount(c38943357.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		-- 判断可放置指示物数量大于0且自己场上存在可以放置魔力指示物的卡。
		if ct>0 and Duel.GetMatchingGroupCount(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,nil,0x1,1)>0
			-- 询问自己是否要在场上放置魔力指示物。
			and Duel.SelectYesNo(tp,aux.Stringid(38943357,0)) then  --"要在场上放置魔力指示物吗？"
			while ct>0 do
				-- 向自己提示选择要放置指示物的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
				-- 让自己从自己场上选择1张可以放置魔力指示物的卡。
				local tc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,nil,0x1,1):GetFirst()
				if not tc then break end
				tc:AddCounter(0x1,1)
				ct=ct-1
			end
		end
	end
end
