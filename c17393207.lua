--墓守の司令官
-- 效果：
-- 把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「王家长眠之谷」加入手卡。
function c17393207.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「王家长眠之谷」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17393207,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c17393207.cost)
	e1:SetTarget(c17393207.target)
	e1:SetOperation(c17393207.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：chk==0时检测此卡能否作为代价送去墓地且能否丢弃；实际支付代价时将这张卡从手卡送去墓地。
function c17393207.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将作为代价的这张卡以「代价+丢弃」的原因从手卡送去墓地，完成丢弃代价的支付。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤：只匹配卡名「王家长眠之谷」且该卡能够加入手卡。
function c17393207.filter(c)
	return c:IsCode(47355498) and c:IsAbleToHand()
end
-- 发动目标判定与检索登记：确认发动时条件满足后，向系统登记本次效果将把卡组的1张卡加入手卡。
function c17393207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者卡组里是否存在至少1张符合条件的「王家长眠之谷」，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17393207.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记操作信息：效果处理时将把1张卡从发动者卡组加入手卡（CATEGORY_TOHAND），用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组找出符合条件的「王家长眠之谷」；若存在则加入手卡并让对方确认，完成检索。
function c17393207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从发动者卡组取得第一张符合条件的「王家长眠之谷」作为检索目标；若无则为nil。
	local tg=Duel.GetFirstMatchingCard(c17393207.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「王家长眠之谷」加入其持有者手卡，原因记为效果处理。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认这张被加入手卡的卡片，以证明检索结果。
		Duel.ConfirmCards(1-tp,tg)
	end
end
