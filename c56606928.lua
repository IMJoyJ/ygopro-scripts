--永遠の渇水
-- 效果：
-- 场上表侧表示存在的鱼族怪兽全部破坏。
function c56606928.initial_effect(c)
	-- 场上表侧表示存在的鱼族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c56606928.target)
	e1:SetOperation(c56606928.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的鱼族怪兽
function c56606928.filter(c)
	return c:IsRace(RACE_FISH) and c:IsFaceup()
end
-- 效果发动的目标检测与准备函数
function c56606928.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查场上是否存在至少1只表侧表示的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56606928.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足过滤条件的鱼族怪兽组
	local sg=Duel.GetMatchingGroup(c56606928.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上所有满足条件的鱼族怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理（激活）函数
function c56606928.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有满足过滤条件的鱼族怪兽组
	local sg=Duel.GetMatchingGroup(c56606928.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏这些怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
