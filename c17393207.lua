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
-- 检查是否可以将此卡送入墓地作为费用并丢弃
function c17393207.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡以送入墓地和丢弃的原因送入墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于检索卡组中「王家长眠之谷」
function c17393207.filter(c)
	return c:IsCode(47355498) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示从卡组检索「王家长眠之谷」加入手卡
function c17393207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「王家长眠之谷」
	if chk==0 then return Duel.IsExistingMatchingCard(c17393207.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将1张卡从卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作，从卡组检索「王家长眠之谷」并加入手卡
function c17393207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「王家长眠之谷」
	local tg=Duel.GetFirstMatchingCard(c17393207.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「王家长眠之谷」加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对手确认加入手卡的「王家长眠之谷」
		Duel.ConfirmCards(1-tp,tg)
	end
end
