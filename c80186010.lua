--キラーザウルス
-- 效果：
-- 把这张卡从手卡丢弃去墓地。从卡组把1张「侏罗纪世界」加入手卡。
function c80186010.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地。从卡组把1张「侏罗纪世界」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80186010,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c80186010.cost)
	e1:SetTarget(c80186010.target)
	e1:SetOperation(c80186010.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否能作为代价丢弃去墓地，并执行送墓操作
function c80186010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将自身作为发动代价丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「侏罗纪世界」且可以加入手牌的卡
function c80186010.filter(c)
	return c:IsCode(10080320) and c:IsAbleToHand()
end
-- 定义效果的目标：检查卡组中是否存在符合条件的卡，并设置将卡片加入手牌的操作信息
function c80186010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80186010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理：从卡组中获取符合条件的卡加入手牌，并给对方确认
function c80186010.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足过滤条件的卡
	local tg=Duel.GetFirstMatchingCard(c80186010.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
