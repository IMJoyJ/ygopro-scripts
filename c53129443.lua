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
-- 检查是否满足效果发动条件并设置连锁操作信息
function c53129443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有怪兽组成的组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏效果，并指定目标怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行效果的处理函数，实现怪兽破坏
function c53129443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽组成的组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将目标怪兽组全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
