--魔力掌握
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。那之后，可以从卡组把1张「魔力掌握」加入手卡。
function c75014062.initial_effect(c)
	-- ①：以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。那之后，可以从卡组把1张「魔力掌握」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,75014062+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c75014062.target)
	e1:SetOperation(c75014062.activate)
	c:RegisterEffect(e1)
end
c75014062.mentioned_counter={
	[0x1]=true,
}
-- 过滤表侧表示且可以放置魔力指示物的卡
function c75014062.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 以场上1张可以放置魔力指示物的卡为对象并设置放置指示物的操作信息
function c75014062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c75014062.filter(chkc) end
	-- 判断场上是否有满足条件的可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 让玩家选择1张满足条件的卡作为对象
	Duel.SelectTarget(tp,c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置放置指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 过滤名为「魔力掌握」且可以加入手卡的卡
function c75014062.tfilter(c)
	return c:IsCode(75014062) and c:IsAbleToHand()
end
-- 给目标放置1个魔力指示物，那之后可以选择将1张「魔力掌握」加入手卡
function c75014062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddCounter(0x1,1) then
		-- 从卡组中获取1张「魔力掌握」
		local th=Duel.GetFirstMatchingCard(c75014062.tfilter,tp,LOCATION_DECK,0,nil)
		-- 如果卡组中有该卡，询问玩家是否将其加入手卡
		if th and Duel.SelectYesNo(tp,aux.Stringid(75014062,0)) then  --"是否要把1张「魔力掌握」加入手牌？"
			-- 中断当前效果以处理加入手卡的后续操作
			Duel.BreakEffect()
			-- 将该卡加入手卡
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,th)
		end
	end
end
