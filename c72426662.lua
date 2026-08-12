--終焉の王デミス
-- 效果：
-- 「世界末日」降临。
-- ①：支付2000基本分才能发动。场上的其他卡全部破坏。
function c72426662.initial_effect(c)
	-- 注册该卡记有「世界末日」卡名的关联关系
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
-- ①效果的发动代价函数，检查并支付2000基本分
function c72426662.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- 让玩家支付2000基本分
	else Duel.PayLPCost(tp,2000) end
end
-- ①效果的发动可行性检查函数（Target）
function c72426662.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在除这张卡以外的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除这张卡以外的所有卡片
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置当前效果包含破坏场上除这张卡以外的所有卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的结算操作函数（Operation）
function c72426662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除了此卡以外的所有卡片作为待破坏卡片
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将选中的所有场上卡片破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
