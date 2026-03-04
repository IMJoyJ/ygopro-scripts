--サンダー・ボルト
-- 效果：
-- ①：对方场上的怪兽全部破坏。
function c12580477.initial_effect(c)
	-- ①：对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12580477.target)
	e1:SetOperation(c12580477.activate)
	c:RegisterEffect(e1)
end
-- 目标函数定义
function c12580477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 发动函数定义
function c12580477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的所有怪兽破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
