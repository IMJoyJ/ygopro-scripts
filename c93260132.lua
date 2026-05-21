--魔法効果の矢
-- 效果：
-- ①：对方场上的表侧表示的魔法卡全部破坏，给与对方破坏数量×500伤害。
function c93260132.initial_effect(c)
	-- ①：对方场上的表侧表示的魔法卡全部破坏，给与对方破坏数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93260132.target)
	e1:SetOperation(c93260132.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的魔法卡
function c93260132.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果发动的目标确认与操作信息设置
function c93260132.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1张表侧表示的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93260132.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的魔法卡
	local sg=Duel.GetMatchingGroup(c93260132.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，包含要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置伤害的操作信息，包含受伤害的玩家和预计伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*500)
end
-- 效果处理的执行函数
function c93260132.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧表示的魔法卡
	local sg=Duel.GetMatchingGroup(c93260132.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏这些魔法卡，并记录实际被破坏的卡片数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	-- 给与对方实际破坏数量×500的伤害
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
