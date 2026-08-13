--神の息吹
-- 效果：
-- 场上表侧表示存在的岩石族怪兽全部破坏。
function c20101223.initial_effect(c)
	-- 场上表侧表示存在的岩石族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20101223.target)
	e1:SetOperation(c20101223.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：筛选出场上的表侧表示且种族为岩石族的怪兽。
function c20101223.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsFaceup()
end
-- 发动时的目标处理：若场上存在符合条件的岩石族怪兽，则获取这些怪兽并设置破坏效果的操作信息。
function c20101223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：检查场上是否存在至少1只表侧表示的岩石族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取当前场上所有表侧表示的岩石族怪兽，作为将要破坏的对象。
	local sg=Duel.GetMatchingGroup(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：宣告将破坏这些岩石族怪兽，数量为获取到的怪兽数量，用于后续连锁判定与效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时的操作：重新获取场上所有表侧表示的岩石族怪兽，并将其全部破坏。
function c20101223.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示的岩石族怪兽，用于执行破坏。
	local sg=Duel.GetMatchingGroup(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将这些岩石族怪兽全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
