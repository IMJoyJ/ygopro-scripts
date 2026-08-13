--天空の使者 ゼラディアス
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「天空的圣域」加入手卡。
-- ②：场上没有「天空的圣域」存在的场合这张卡破坏。
function c12171659.initial_effect(c)
	-- 将卡名「天空的圣域」（密码56433456）登记进本卡的代码列表，用于标记效果文本中提到的这张关联卡。
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
-- 效果①的代价函数：检查阶段判定这张卡能否从手卡丢弃作为COST；发动时把自身从手卡送去墓地并标记为代价丢弃。
function c12171659.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 以“代价+丢弃”的原因将作为COST的这张卡从手卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：目标卡必须是「天空的圣域」（56433456），且能够被加入手卡。
function c12171659.filter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- 效果①的发动目标处理：检查卡组中是否存在可检索的「天空的圣域」，并设置这次效果的操作信息为从卡组把1张卡加入手卡。
function c12171659.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：己方卡组中存在至少1张满足过滤条件的「天空的圣域」才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c12171659.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时会把1张卡从卡组加入手卡，供相关效果或时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的解决处理：从卡组选取1张「天空的圣域」送入持有者手卡，并向对方玩家展示。
function c12171659.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方卡组取得第一张满足过滤条件的「天空的圣域」，若不存在则为nil。
	local tg=Duel.GetFirstMatchingCard(c12171659.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 以效果原因将这张「天空的圣域」加入其持有者的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家确认这张刚检索到的「天空的圣域」，使检索结果公开。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 效果②的自毁条件函数：满足“场上没有「天空的圣域」存在”这一条件时，这张卡将自毁。
function c12171659.descon(e)
	-- 返回“场上不存在卡号为56433456的「天空的圣域」环境”这一判定结果。
	return not Duel.IsEnvironment(56433456)
end
