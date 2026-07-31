--魔力統轄
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「恩底弥翁」卡加入手卡。那之后，可以给自己场上的可以放置魔力指示物的卡尽可能放置最多有自己的场上·墓地的「魔力统辖」「魔力掌握」数量的魔力指示物。
function c38943357.initial_effect(c)
	-- 效果定义：将魔力统辖这张卡的发动次数限制为每回合最多1次，且只能从卡组检索「恩底弥翁」卡加入手牌，并可选择是否在场上放置魔力指示物。
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
-- 过滤函数：用于筛选可以加入手牌的「恩底弥翁」卡。
function c38943357.filter(c)
	return c:IsSetCard(0x12a) and c:IsAbleToHand()
end
-- 效果目标函数：检查是否能从卡组检索一张「恩底弥翁」卡，若可以则设置操作信息为检索卡组中的卡。
function c38943357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：在效果处理阶段检查是否存在满足条件的「恩底弥翁」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38943357.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：设定本次连锁将要处理的卡为从卡组检索的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：用于筛选自己场上的「魔力统辖」或「魔力掌握」卡，无论是否表侧表示或在墓地。
function c38943357.cfilter(c)
	return c:IsCode(38943357,75014062) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果处理函数：执行检索卡组中的「恩底弥翁」卡并加入手牌，并根据条件决定是否放置魔力指示物。
function c38943357.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中的「恩底弥翁」卡：从卡组中选择一张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,c38943357.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功检索并加入手牌：若成功则继续执行后续操作。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方查看卡牌：向对方玩家展示所选的卡牌。
		Duel.ConfirmCards(1-tp,g)
		-- 统计自己场上的「魔力统辖」或「魔力掌握」数量：用于决定最多可放置多少个魔力指示物。
		local ct=Duel.GetMatchingGroupCount(c38943357.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		-- 判断是否可以放置魔力指示物：检查场上是否有可放置魔力指示物的卡。
		if ct>0 and Duel.GetMatchingGroupCount(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,nil,0x1,1)>0
			-- 询问玩家是否放置魔力指示物：向玩家提示是否要进行后续操作。
			and Duel.SelectYesNo(tp,aux.Stringid(38943357,0)) then  --"要在场上放置魔力指示物吗？"
			while ct>0 do
				-- 提示选择：向玩家提示选择要放置魔力指示物的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
				-- 选择可以放置魔力指示物的卡：从场上选择一张可放置魔力指示物的卡。
				local tc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,nil,0x1,1):GetFirst()
				if not tc then break end
				tc:AddCounter(0x1,1)
				ct=ct-1
			end
		end
	end
end
