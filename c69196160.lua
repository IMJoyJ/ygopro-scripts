--サンダー・クラッシュ
-- 效果：
-- 破坏自己场上存在的所有怪兽。对对方造成被破坏的怪兽数量×300点的伤害。
function c69196160.initial_effect(c)
	-- 破坏自己场上存在的所有怪兽。对对方造成被破坏的怪兽数量×300点的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69196160.target)
	e1:SetOperation(c69196160.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与操作信息设置函数
function c69196160.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只怪兽作为发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 设置破坏自己场上所有怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置给与对方被破坏数量×300伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*300)
end
-- 效果处理的执行函数
function c69196160.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 破坏这些怪兽，并获取实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给与对方实际被破坏数量×300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
