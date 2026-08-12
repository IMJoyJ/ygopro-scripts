--グランドクロス
-- 效果：
-- 自己场上有「大宇宙」存在时才能发动。给与对方基本分300分伤害，场上的怪兽全部破坏。
function c38430673.initial_effect(c)
	-- 记录此卡具有「大宇宙」的卡片密码，用于条件判断
	aux.AddCodeList(c,30241314)
	-- 自己场上有「大宇宙」存在时才能发动。给与对方基本分300分伤害，场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c38430673.condition)
	e1:SetTarget(c38430673.target)
	e1:SetOperation(c38430673.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「大宇宙」
function c38430673.filter(c)
	return c:IsFaceup() and c:IsCode(30241314)
end
-- 效果发动条件，检查自己场上是否存在「大宇宙」
function c38430673.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「大宇宙」
	return Duel.IsExistingMatchingCard(c38430673.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置连锁处理时的Operation信息，包括造成伤害和破坏怪兽
function c38430673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置造成300分伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
	-- 设置破坏场上所有怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时执行的操作，包括造成伤害和破坏怪兽
function c38430673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方造成300分伤害
	Duel.Damage(1-tp,300,REASON_EFFECT)
	-- 获取场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将场上所有怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
