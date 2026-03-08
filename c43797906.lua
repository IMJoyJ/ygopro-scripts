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
-- 检查是否可以将此卡作为发动代价丢入墓地
function c43797906.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡以效果和丢弃原因送入墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于检索卡组中编号为295517的「传说之都 亚特兰蒂斯」卡片
function c43797906.filter(c)
	return c:GetOriginalCode()==295517 and c:IsAbleToHand()
end
-- 设置连锁处理信息，确定效果发动时会从卡组检索1张「传说之都 亚特兰蒂斯」加入手卡
function c43797906.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在满足条件的「传说之都 亚特兰蒂斯」
	if chk==0 then return Duel.IsExistingMatchingCard(c43797906.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为卡组中的一张「传说之都 亚特兰蒂斯」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行从卡组检索并加入手卡的操作
function c43797906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「传说之都 亚特兰蒂斯」
	local tg=Duel.GetFirstMatchingCard(c43797906.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「传说之都 亚特兰蒂斯」送入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认翻开的「传说之都 亚特兰蒂斯」
		Duel.ConfirmCards(1-tp,tg)
	end
end
