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
-- 指示物过滤条件：表侧表示且可放置0x1（魔力）指示物
function c75014062.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 效果发动准备：选择场上1张可放置魔力指示物的卡为对象并设置放置指示物操作信息
function c75014062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c75014062.filter(chkc) end
	-- 发动条件检查：场上是否存在可放置魔力指示物的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择场上1张表侧表示卡作为对象
	Duel.SelectTarget(tp,c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：放置1个0x1（魔力）指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 检索过滤条件：卡号为75014062（魔力掌握）且可加入手牌
function c75014062.tfilter(c)
	return c:IsCode(75014062) and c:IsAbleToHand()
end
-- 效果处理：给对象卡放置1个魔力指示物，成功时可从卡组把1张「魔力掌握」加入手牌
function c75014062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddCounter(0x1,1) then
		-- 获取卡组中第一张「魔力掌握」
		local th=Duel.GetFirstMatchingCard(c75014062.tfilter,tp,LOCATION_DECK,0,nil)
		-- 检查卡组是否存在「魔力掌握」并询问玩家是否加入手牌
		if th and Duel.SelectYesNo(tp,aux.Stringid(75014062,0)) then  --"是否要把1张「魔力掌握」加入手牌？"
			-- 连接效果块（分隔放置指示物与加入手牌的操作）
			Duel.BreakEffect()
			-- 将卡组中的「魔力掌握」加入手牌
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,th)
		end
	end
end
