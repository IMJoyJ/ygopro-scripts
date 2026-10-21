--トークン謝肉祭
-- 效果：
-- 衍生物特殊召唤时发动。场上存在的全部衍生物破坏，与对方基本分破坏的衍生物数量×300分的伤害。
function c83675475.initial_effect(c)
	-- 衍生物特殊召唤时发动。场上存在的全部衍生物破坏，与对方基本分破坏的衍生物数量×300分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c83675475.condition)
	e1:SetTarget(c83675475.target)
	e1:SetOperation(c83675475.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：有衍生物特殊召唤成功
function c83675475.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_TOKEN)
end
-- 效果处理：登记破坏场上全部衍生物并给予伤害的操作信息
function c83675475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	-- 设置操作信息：破坏场上的全部衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：给予对方破坏衍生物数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*300)
end
-- 效果处理：破坏场上全部衍生物并给予对方伤害
function c83675475.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	-- 破坏场上所有的衍生物并获取破坏数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给予对方破坏衍生物数量×300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
