--酸の嵐
-- 效果：
-- 场上表侧表示存在的机械族怪兽全部破坏。
function c21323861.initial_effect(c)
	-- 场上表侧表示存在的机械族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21323861.target)
	e1:SetOperation(c21323861.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示且种族为机械族的怪兽，作为本卡的破坏对象条件。
function c21323861.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 效果发动时的目标判定与操作信息设置：先确认场上是否存在符合条件的机械族怪兽，若存在则取得全部这类怪兽并设置破坏的操作信息。
function c21323861.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的合法性检查：仅在场上存在至少1只表侧表示机械族怪兽时才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21323861.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发动时收集场上全部表侧表示机械族怪兽，用于向系统登记即将破坏的候选对象。
	local sg=Duel.GetMatchingGroup(c21323861.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁的处理信息设置为“破坏”，对象为场上全部表侧表示机械族怪兽，数量为这些怪兽的数量，供其他卡牌效果连锁判断时参考。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时执行破坏：重新获取场上全部表侧表示机械族怪兽，并将其全部破坏（不取对象，处理时判定）。
function c21323861.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检索场上全部表侧表示机械族怪兽，确保按处理时场上存在的卡进行破坏。
	local sg=Duel.GetMatchingGroup(c21323861.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以‘效果’为破坏原因，将所选机械族怪兽全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
