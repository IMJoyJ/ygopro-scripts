--魔女狩り
-- 效果：
-- 场上表侧表示的魔法师族的怪兽全部破坏。
function c90330453.initial_effect(c)
	-- 场上表侧表示的魔法师族的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90330453.target)
	e1:SetOperation(c90330453.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c90330453.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
-- 效果发动的目标检查与准备
function c90330453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查场上是否存在至少1只表侧表示的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90330453.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示的魔法师族怪兽的卡片组
	local sg=Duel.GetMatchingGroup(c90330453.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上所有的这些魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行：破坏场上所有表侧表示的魔法师族怪兽
function c90330453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时场上所有表侧表示的魔法师族怪兽
	local sg=Duel.GetMatchingGroup(c90330453.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽因效果全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
