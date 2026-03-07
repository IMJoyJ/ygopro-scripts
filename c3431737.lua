--バスター・ビースト
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「爆裂模式」加入手卡。
function c3431737.initial_effect(c)
	-- 记录此卡具有「爆裂模式」的卡名信息
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
-- 检查是否可以将此卡送入墓地作为代价并丢弃此卡
function c3431737.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡送入墓地并丢弃
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选卡组中「爆裂模式」卡片
function c3431737.filter(c)
	return c:IsCode(80280737) and c:IsAbleToHand()
end
-- 检查卡组中是否存在满足条件的「爆裂模式」卡片，并设置操作信息
function c3431737.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在至少1张「爆裂模式」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c3431737.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张「爆裂模式」加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作，从卡组检索「爆裂模式」并加入手卡
function c3431737.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「爆裂模式」卡片
	local tc=Duel.GetFirstMatchingCard(c3431737.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「爆裂模式」卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认展示检索到的「爆裂模式」卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
