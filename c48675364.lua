--ジェネラルデーモン
-- 效果：
-- 把这张卡从手卡丢弃去墓地。从卡组把1张「万魔殿-恶魔的巢窟-」加入手卡。场上没有「万魔殿-恶魔的巢窟-」存在的场合，场上的这张卡破坏。
function c48675364.initial_effect(c)
	-- 记录此卡具有「万魔殿-恶魔的巢窟-」这张卡的卡片编号
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
-- 支付效果代价：将此卡送去墓地
function c48675364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡因支付代价而送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义用于检索的过滤函数，筛选「万魔殿-恶魔的巢窟-」并可加入手牌
function c48675364.filter(c)
	return c:IsCode(94585852) and c:IsAbleToHand()
end
-- 设置效果目标：从卡组检索1张「万魔殿-恶魔的巢窟-」
function c48675364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在「万魔殿-恶魔的巢窟-」
	if chk==0 then return Duel.IsExistingMatchingCard(c48675364.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为卡组中的一张「万魔殿-恶魔的巢窟-」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作：从卡组检索并加入手牌
function c48675364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的第一张「万魔殿-恶魔的巢窟-」
	local tg=Duel.GetFirstMatchingCard(c48675364.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对手确认该卡
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 定义破坏条件函数：当场上不存在「万魔殿-恶魔的巢窟-」时触发破坏
function c48675364.descon(e)
	-- 判断当前场地是否不是「万魔殿-恶魔的巢窟-」
	return not Duel.IsEnvironment(94585852)
end
