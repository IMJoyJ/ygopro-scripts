--No.91 サンダー・スパーク・ドラゴン
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，可以把这张卡的超量素材的以下数量取除，那个效果发动。
-- ●3个：这张卡以外的场上的表侧表示怪兽全部破坏。
-- ●5个：对方场上的卡全部破坏。
function c84417082.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以把这张卡的超量素材的以下数量取除，那个效果发动。●3个：这张卡以外的场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84417082,0))  --"3个：这张卡以外的表侧表示怪兽全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(c84417082.cost1)
	e1:SetTarget(c84417082.target1)
	e1:SetOperation(c84417082.operation1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以把这张卡的超量素材的以下数量取除，那个效果发动。●5个：对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84417082,1))  --"5个：对方场上的卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c84417082.cost2)
	e2:SetTarget(c84417082.target2)
	e2:SetOperation(c84417082.operation2)
	c:RegisterEffect(e2)
end
-- 设置该卡片的「No.」编号为91
aux.xyz_number[84417082]=91
-- 效果1（去除3个素材）的代价（Cost）函数：检查并去除3个超量素材
function c84417082.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	-- 向对方玩家提示选择发动了效果1（去除3个素材的效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 过滤条件：表侧表示的卡
function c84417082.filter1(c)
	return c:IsFaceup()
end
-- 效果1（去除3个素材）的目标（Target）函数：检查并设置破坏场上除自身外所有表侧表示怪兽的操作信息
function c84417082.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只这张卡以外的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84417082.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c84417082.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置效果处理信息：破坏场上除自身外所有的表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果1（去除3个素材）的效果处理（Operation）函数：破坏场上除自身外所有的表侧表示怪兽
function c84417082.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有表侧表示怪兽（若自身已离场则不排除）
	local g=Duel.GetMatchingGroup(c84417082.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 破坏获取到的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果2（去除5个素材）的代价（Cost）函数：检查并去除5个超量素材
function c84417082.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,5,REASON_COST) end
	-- 向对方玩家提示选择发动了效果2（去除5个素材的效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,5,5,REASON_COST)
end
-- 效果2（去除5个素材）的目标（Target）函数：检查并设置破坏对方场上所有卡的操作信息
function c84417082.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果2（去除5个素材）的效果处理（Operation）函数：破坏对方场上的所有卡
function c84417082.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏对方场上的所有卡
	Duel.Destroy(g,REASON_EFFECT)
end
