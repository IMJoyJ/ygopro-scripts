--ハーピィ・クィーン
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「鹰身女妖的狩猎场」加入手卡。
function c75064463.initial_effect(c)
	-- 注册卡片记有「鹰身女妖的狩猎场」卡名的信息
	aux.AddCodeList(c,75782277)
	-- ②：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「鹰身女妖的狩猎场」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75064463,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c75064463.cost)
	e1:SetTarget(c75064463.target)
	e1:SetOperation(c75064463.operation)
	c:RegisterEffect(e1)
	-- 设置这张卡在场上·墓地存在时卡名当作「鹰身女郎」使用的效果
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 效果②的发动代价函数：检查并执行将自身从手卡丢弃去墓地
function c75064463.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 作为发动代价，将这张卡丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名为「鹰身女妖的狩猎场」且可以加入手卡的卡
function c75064463.filter(c)
	return c:IsCode(75782277) and c:IsAbleToHand()
end
-- 效果②的发动准备函数：检查卡组中是否存在目标卡，并设置检索的操作信息
function c75064463.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c75064463.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数：从卡组将1张「鹰身女妖的狩猎场」加入手卡并给对方确认
function c75064463.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足过滤条件的卡（即「鹰身女妖的狩猎场」）
	local tg=Duel.GetFirstMatchingCard(c75064463.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片加入玩家手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,tg)
	end
end
