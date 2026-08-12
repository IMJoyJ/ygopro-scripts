--裁きの龍
-- 效果：
-- 这张卡不能通常召唤。自己墓地的「光道」怪兽是4种类以上的场合才能特殊召唤。
-- ①：支付1000基本分才能发动。场上的其他卡全部破坏。
-- ②：自己结束阶段发动。从自己卡组上面把4张卡送去墓地。
function c57774843.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己墓地的「光道」怪兽是4种类以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57774843,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c57774843.spcon)
	c:RegisterEffect(e1)
	-- ①：支付1000基本分才能发动。场上的其他卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(57774843,1))  --"这张卡以外的场上的卡全部破坏"
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c57774843.cost)
	e2:SetTarget(c57774843.target)
	e2:SetOperation(c57774843.operation)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。从自己卡组上面把4张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetDescription(aux.Stringid(57774843,2))  --"从自己卡组上面把4张卡送去墓地"
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c57774843.condition2)
	e3:SetTarget(c57774843.target2)
	e3:SetOperation(c57774843.operation2)
	c:RegisterEffect(e3)
	-- 这张卡不能通常召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地的「光道」怪兽
function c57774843.spfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件判断函数，检查怪兽区域空格以及墓地「光道」怪兽种类是否在4种以上
function c57774843.spcon(e,c)
	if c==nil then return true end
	-- 检查自身怪兽区域是否有可用的空格
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取自己墓地所有的「光道」怪兽
	local g=Duel.GetMatchingGroup(c57774843.spfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end
-- 破坏效果的发动代价处理函数，检查并支付1000基本分
function c57774843.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 破坏效果的发动目标确认与操作信息设置函数
function c57774843.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，检查场上是否存在除这张卡以外的至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除这张卡以外的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁的操作信息，表明此效果将破坏这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的实际执行函数
function c57774843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有卡（排除自身）
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏获取到的卡片组
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 结束阶段送墓效果的发动条件判断函数，必须是自己的结束阶段
function c57774843.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 结束阶段送墓效果的发动目标确认与操作信息设置函数
function c57774843.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果将从自己卡组上面把4张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- 结束阶段送墓效果的实际执行函数
function c57774843.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组上面把4张卡送去墓地
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
