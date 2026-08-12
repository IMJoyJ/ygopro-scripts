--海竜－ダイダロス
-- 效果：
-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。这张卡以外的场上的卡全部破坏。
function c37721209.initial_effect(c)
	-- 注册此卡具有「海」字段的卡片编号
	aux.AddCodeList(c,22702055)
	-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。这张卡以外的场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37721209,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c37721209.cost)
	e1:SetTarget(c37721209.target)
	e1:SetOperation(c37721209.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的「海」卡且可以作为cost送去墓地
function c37721209.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 效果处理时的cost阶段，检查场上是否存在满足条件的「海」卡并选择一张送去墓地
function c37721209.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37721209.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张「海」卡
	local g=Duel.SelectMatchingCard(tp,c37721209.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理时的target阶段，检查场上是否存在除这张卡外的其他场上卡
function c37721209.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡外至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有除这张卡外的卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息，指定将要破坏的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的operation阶段，将场上所有除这张卡外的卡破坏
function c37721209.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有除这张卡外的卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将指定的卡组全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
