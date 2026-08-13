--アトランティスの戦士
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「传说之都 亚特兰蒂斯」加入手卡。
function c43797906.initial_effect(c)
	-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「传说之都 亚特兰蒂斯」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43797906,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c43797906.cost)
	e1:SetTarget(c43797906.target)
	e1:SetOperation(c43797906.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：效果发动时先判定此卡能否作为代价从手卡丢弃去墓地；判定通过后，实际发动时执行丢弃动作。
function c43797906.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡从手卡以代价+丢弃的原因送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：卡名原始卡号为295517（即「传说之都 亚特兰蒂斯」）且该卡能被加入手卡。
function c43797906.filter(c)
	return c:GetOriginalCode()==295517 and c:IsAbleToHand()
end
-- 目标判定函数：检查自己卡组是否存在符合条件的「传说之都 亚特兰蒂斯」，若存在则允许发动并登记检索加入手卡的操作信息。
function c43797906.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己卡组存在至少1张符合条件的「传说之都 亚特兰蒂斯」。
	if chk==0 then return Duel.IsExistingMatchingCard(c43797906.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果处理时将检索1张卡加入手卡，目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从自己卡组选出符合条件的「传说之都 亚特兰蒂斯」，将其加入手卡，并让对方确认。
function c43797906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组获取第1张符合条件的「传说之都 亚特兰蒂斯」。
	local tg=Duel.GetFirstMatchingCard(c43797906.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「传说之都 亚特兰蒂斯」加入其持有者的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示检索到并加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tg)
	end
end
