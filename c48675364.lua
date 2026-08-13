--ジェネラルデーモン
-- 效果：
-- 把这张卡从手卡丢弃去墓地。从卡组把1张「万魔殿-恶魔的巢窟-」加入手卡。场上没有「万魔殿-恶魔的巢窟-」存在的场合，场上的这张卡破坏。
function c48675364.initial_effect(c)
	-- 将该卡卡名中记载的「万魔殿-恶魔的巢窟-」（卡号94585852）登记到代码列表中，用于后续检索效果中识别相关卡名。
	aux.AddCodeList(c,94585852)
	-- 把这张卡从手卡丢弃去墓地。从卡组把1张「万魔殿-恶魔的巢窟-」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48675364,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c48675364.cost)
	e1:SetTarget(c48675364.target)
	e1:SetOperation(c48675364.operation)
	c:RegisterEffect(e1)
	-- 场上没有「万魔殿-恶魔的巢窟-」存在的场合，场上的这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c48675364.descon)
	c:RegisterEffect(e2)
end
-- 发动代价函数：检查这张卡是否可作为代价送去墓地且能丢弃；满足条件时实际将手卡的这张卡丢弃去墓地。
function c48675364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 以“代价”和“丢弃”为理由将这张卡从手卡送去墓地，完成发动代价的支付。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：卡名是「万魔殿-恶魔的巢窟-」（94585852），并且这张卡能够加入手卡。
function c48675364.filter(c)
	return c:IsCode(94585852) and c:IsAbleToHand()
end
-- 效果发动目标函数：在发动时判断卡组是否存在符合条件的「万魔殿-恶魔的巢窟-」，并设置效果处理时将卡组1张卡加入手卡的操作信息。
function c48675364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组中存在至少1张满足条件的「万魔殿-恶魔的巢窟-」且其能够加入手卡时，效果才可能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48675364.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果处理时会将1张卡从卡组加入手卡（CATEGORY_TOHAND），供后续连锁判定等机制参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：实际从卡组检索符合条件的「万魔殿-恶魔的巢窟-」加入手卡，并向对方确认检索到的卡。
function c48675364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取第一张满足检索条件的「万魔殿-恶魔的巢窟-」，若没有则为nil。
	local tg=Duel.GetFirstMatchingCard(c48675364.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「万魔殿-恶魔的巢窟-」以效果理由加入其持有者的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的「万魔殿-恶魔的巢窟-」，确认检索结果。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 自我破坏效果的诱发条件函数：场上不存在「万魔殿-恶魔的巢窟-」时条件成立。
function c48675364.descon(e)
	-- 判定当前场上是否不存在「万魔殿-恶魔的巢窟-」；若不存在则返回true，使该怪兽自我破坏。
	return not Duel.IsEnvironment(94585852)
end
