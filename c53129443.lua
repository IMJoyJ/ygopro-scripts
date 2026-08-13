--ブラック・ホール
-- 效果：
-- ①：场上的怪兽全部破坏。
function c53129443.initial_effect(c)
	-- ①：场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c53129443.target)
	e1:SetOperation(c53129443.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标检查与操作信息设定：确认场上有怪兽存在，并将双方场上所有怪兽登记为将被本次效果破坏的对象（不取对象）。
function c53129443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只怪兽；若无则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上全部怪兽作为可能被破坏的集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将破坏对象信息（全部怪兽及数量）写入连锁操作信息，供后续效果联动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时取得当前双方场上所有怪兽并将其全部破坏。
function c53129443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前双方场上所有怪兽的集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果为原因破坏这些怪兽。
	Duel.Destroy(sg,REASON_EFFECT)
end
