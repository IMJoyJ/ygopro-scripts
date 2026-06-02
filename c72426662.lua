--終焉の王デミス
-- 效果：
-- 「世界末日」降临。
-- ①：支付2000基本分才能发动。场上的其他卡全部破坏。
function c72426662.initial_effect(c)
	aux.AddCodeList(c,8198712)
	c:EnableReviveLimit()
	-- ①：支付2000基本分才能发动。场上的其他卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(72426662,0))  --"此卡以外全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c72426662.cost)
	e1:SetTarget(c72426662.target)
	e1:SetOperation(c72426662.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数，用于检查和支付2000基本分
function c72426662.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- 在发动时，扣除玩家2000基本分作为代价
	else Duel.PayLPCost(tp,2000) end
end
-- 定义效果发动目标函数，检查场上是否存在其他卡并注册破坏操作信息
function c72426662.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动准备阶段，检查场上是否存在至少1张除此卡以外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除此卡以外的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息，表明此效果将破坏获取到的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义效果处理函数，执行破坏场上其他卡的操作
function c72426662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除此卡以外的所有卡（若此卡已不在场则获取场上所有的卡）
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果破坏这些卡
	Duel.Destroy(sg,REASON_EFFECT)
end
