--海竜－ダイダロス
-- 效果：
-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。这张卡以外的场上的卡全部破坏。
function c37721209.initial_effect(c)
	-- 将「海」的卡号22702055登记为这张卡的关联卡名，用于在规则处理中识别这张卡记载了「海」这一卡名。
	aux.AddCodeList(c,22702055)
	-- ①：把自己场上1张表侧表示的「海」送去墓地才能发动。场上的其他卡全部破坏。
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
-- 代价筛选条件：候选卡必须是表侧表示、卡名为「海」(22702055)且能够作为代价送去墓地。
function c37721209.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 代价处理：先检查能否支付，若可以则从自己场上表侧表示的「海」中选择1张送入墓地作为发动代价。
function c37721209.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1张满足筛选条件的表侧表示的「海」。
	if chk==0 then return Duel.IsExistingMatchingCard(c37721209.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示，要求玩家选择一张要送去墓地的卡（用于送墓「海」作为代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张符合条件的表侧表示的「海」作为代价卡。
	local g=Duel.SelectMatchingCard(tp,c37721209.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的「海」以代价（REASON_COST）方式送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的目标合法性检查与操作信息登记：确认场上存在这张卡以外的其他卡，并预先登记破坏分类及数量。
function c37721209.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：判断场上是否存在至少1张除这张卡自身以外的卡（即可以被破坏的其他卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取当前场上除自身以外的所有卡（不取对象，效果处理时才实际决定破坏对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：本次效果将破坏上述其他卡，类别为CATEGORY_DESTROY，数量为组内卡数g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得场上除自身以外的全部卡并全部破坏。
function c37721209.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除自身以外的所有卡（通过aux.ExceptThisCard(e)排除效果发动者自身）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将取得的这些卡全部以效果（REASON_EFFECT）破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
