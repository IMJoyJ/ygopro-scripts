--戒めの龍
-- 效果：
-- 这张卡不能通常召唤。自己的除外状态的「光道」怪兽是4种类以上的场合才能特殊召唤。
-- ①：自己·对方回合1次，支付1000基本分才能发动。「光道」怪兽以外的双方的墓地·除外状态（表侧）的卡全部回到卡组。
-- ②：1回合1次，自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把4张卡送去墓地。
function c19959563.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 自己的除外状态的「光道」怪兽是4种类以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19959563.spcon)
	c:RegisterEffect(e1)
	-- 自己·对方回合1次，支付1000基本分才能发动。「光道」怪兽以外的双方的墓地·除外状态（表侧）的卡全部回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19959563,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c19959563.cost)
	e2:SetTarget(c19959563.target)
	e2:SetOperation(c19959563.operation)
	c:RegisterEffect(e2)
	-- 1回合1次，自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把4张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19959563,1))
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c19959563.ddcon)
	e4:SetTarget(c19959563.ddtg)
	e4:SetOperation(c19959563.ddop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断除外状态的「光道」怪兽
function c19959563.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤条件函数，检查除外状态的「光道」怪兽种类是否超过4种
function c19959563.spcon(e,c)
	if c==nil then return true end
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取玩家除外区域中所有「光道」怪兽的集合
	local g=Duel.GetMatchingGroup(c19959563.spfilter,c:GetControler(),LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end
-- 支付1000基本分的费用函数
function c19959563.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断哪些卡可以送回卡组
function c19959563.filter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not (c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)) and c:IsAbleToDeck()
end
-- 设置效果发动时的目标信息，准备将符合条件的卡送回卡组
function c19959563.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,e:GetHandler()) end
	-- 获取所有满足条件的卡的集合
	local g=Duel.GetMatchingGroup(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	-- 设置操作信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果发动时执行的操作，将符合条件的卡送回卡组
function c19959563.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的卡的集合
	local g=Duel.GetMatchingGroup(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	-- 检查是否因王家长眠之谷而无效
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 连锁触发条件函数，判断是否为己方「光道」怪兽的效果发动
function c19959563.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x38) and rc:IsControler(tp)
end
-- 设置效果发动时的目标信息，准备从卡组丢弃4张卡
function c19959563.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将从卡组丢弃4张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- 效果发动时执行的操作，从卡组丢弃4张卡
function c19959563.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 从玩家卡组最上方丢弃4张卡
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
