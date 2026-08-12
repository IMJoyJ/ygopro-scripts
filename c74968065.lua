--ヘカテリス
-- 效果：
-- ①：自己主要阶段把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「神之居城-瓦尔哈拉」加入手卡。
function c74968065.initial_effect(c)
	-- ①：自己主要阶段把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「神之居城-瓦尔哈拉」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74968065,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c74968065.cost)
	e1:SetTarget(c74968065.target)
	e1:SetOperation(c74968065.operation)
	c:RegisterEffect(e1)
end
-- 代价检查与支付：检查自身是否可以作为代价丢弃送去墓地，并执行丢弃操作
function c74968065.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将自身作为发动代价丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：过滤卡组中卡名为「神之居城-瓦尔哈拉」且能加入手牌的卡
function c74968065.filter(c)
	return c:IsCode(1353770) and c:IsAbleToHand()
end
-- 效果发动准备：检查卡组中是否存在满足条件的卡，并设置效果分类为检索/加入手牌
function c74968065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张「神之居城-瓦尔哈拉」
	if chk==0 then return Duel.IsExistingMatchingCard(c74968065.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理是将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1张「神之居城-瓦尔哈拉」加入手牌并给对方确认
function c74968065.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取卡组中第一张满足条件的「神之居城-瓦尔哈拉」
	local tg=Duel.GetFirstMatchingCard(c74968065.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
