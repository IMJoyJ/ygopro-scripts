--E・HERO キャプテン・ゴールド
-- 效果：
-- 把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「摩天楼」加入手卡。此外，场上没有「摩天楼」存在的场合，这张卡破坏。
function c80908502.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「摩天楼」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80908502,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c80908502.cost)
	e1:SetTarget(c80908502.target)
	e1:SetOperation(c80908502.operation)
	c:RegisterEffect(e1)
	-- 此外，场上没有「摩天楼」存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c80908502.descon)
	c:RegisterEffect(e2)
end
-- 发动代价（Cost）函数：验证并执行将自身从手卡丢弃去墓地的代价
function c80908502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将自身作为代价丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名是「摩天楼」且可以加入手卡的卡
function c80908502.filter(c)
	return c:IsCode(63035430) and c:IsAbleToHand()
end
-- 效果发动准备（Target）函数：验证卡组中是否存在「摩天楼」并向系统宣告该效果会将卡加入手卡
function c80908502.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80908502.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）函数：从卡组检索「摩天楼」加入手卡并给对方确认
function c80908502.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索第一张满足过滤条件的卡（即「摩天楼」）
	local tg=Duel.GetFirstMatchingCard(c80908502.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片加入玩家手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 自我破坏效果的条件函数：检查场上是否存在「摩天楼」
function c80908502.descon(e)
	-- 检查场上（包括场地卡槽）是否存在「摩天楼」，若不存在则满足破坏条件
	return not Duel.IsEnvironment(63035430)
end
