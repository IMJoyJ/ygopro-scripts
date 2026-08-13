--バスター・ビースト
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「爆裂模式」加入手卡。
function c3431737.initial_effect(c)
	-- 将卡号80280737（「爆裂模式」）登记到本卡的代码列表，表示本卡效果文本中记载了该卡名，供规则/效果查询使用。
	aux.AddCodeList(c,80280737)
	-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「爆裂模式」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3431737,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c3431737.cost)
	e1:SetTarget(c3431737.target)
	e1:SetOperation(c3431737.operation)
	c:RegisterEffect(e1)
end
-- 发动代价函数：判定并执行把这张卡从手卡丢弃去墓地的代价；chk==0时仅检查是否可作为代价丢弃，否则实际执行丢弃。
function c3431737.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将作为代价的这张卡从手卡以丢弃代价的形式送入墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：判定卡是否为「爆裂模式」（80280737），并且能够加入手卡。
function c3431737.filter(c)
	return c:IsCode(80280737) and c:IsAbleToHand()
end
-- 效果发动目标与操作信息设置：确认卡组中存在符合条件的「爆裂模式」，并设置后续将卡加入手卡的处理信息。
function c3431737.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中是否存在1张满足过滤条件的「爆裂模式」。
	if chk==0 then return Duel.IsExistingMatchingCard(c3431737.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：本次效果将从卡组把1张卡加入手卡（CATEGORY_TOHAND），供后续效果/时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组中检索1张「爆裂模式」加入手卡，若检索到则向对方玩家展示。
function c3431737.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组中选取第一张符合条件的「爆裂模式」作为要加入手卡的卡。
	local tc=Duel.GetFirstMatchingCard(c3431737.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「爆裂模式」加入其持有者的手卡，原因标记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 把加入手卡的那张「爆裂模式」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
