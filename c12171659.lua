--天空の使者 ゼラディアス
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「天空的圣域」加入手卡。
-- ②：场上没有「天空的圣域」存在的场合这张卡破坏。
function c12171659.initial_effect(c)
	-- 为卡片注册「天空的圣域」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,56433456)
	-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「天空的圣域」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12171659,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c12171659.cost)
	e1:SetTarget(c12171659.target)
	e1:SetOperation(c12171659.operation)
	c:RegisterEffect(e1)
	-- ②：场上没有「天空的圣域」存在的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c12171659.descon)
	c:RegisterEffect(e2)
end
-- 效果的发动费用函数，用于检查是否满足丢弃条件并执行丢弃操作
function c12171659.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将该卡从手卡丢弃至墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 用于过滤卡组中「天空的圣域」卡片的函数
function c12171659.filter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- 效果的目标选择函数，用于判断是否能检索「天空的圣域」
function c12171659.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「天空的圣域」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c12171659.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张「天空的圣域」加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，用于执行检索并展示卡片
function c12171659.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「天空的圣域」卡片
	local tg=Duel.GetFirstMatchingCard(c12171659.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「天空的圣域」加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对手确认展示检索到的「天空的圣域」卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 判断该卡是否需要因场上无「天空的圣域」而破坏的条件函数
function c12171659.descon(e)
	-- 判断当前场上是否没有「天空的圣域」场地卡
	return not Duel.IsEnvironment(56433456)
end
