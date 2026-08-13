--昇霊術師 ジョウゲン
-- 效果：
-- 把手卡随机1张丢弃去墓地才能发动。场上的特殊召唤的怪兽全部破坏。此外，只要这张卡在场上表侧表示存在，双方不能把怪兽特殊召唤。
function c41855169.initial_effect(c)
	-- 此外，只要这张卡在场上表侧表示存在，双方不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
	-- 把手卡随机1张丢弃去墓地才能发动。场上的特殊召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41855169,0))  --"特殊召唤的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c41855169.cost)
	e2:SetTarget(c41855169.target)
	e2:SetOperation(c41855169.operation)
	c:RegisterEffect(e2)
end
-- 作为代价可丢弃手卡的过滤条件：需要能够丢弃、能够作为代价送去墓地，且不受“不能丢弃”效果影响。
function c41855169.cfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and not c:IsHasEffect(81674782)
end
-- 发动代价处理：从手卡中随机选择1张卡送去墓地作为发动代价。
function c41855169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查是否存在满足代价条件的手卡，若存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41855169.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 取得我方全部手卡，用于后续随机选择。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的1张手卡以“代价+丢弃”的原因送去墓地，完成发动代价。
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
-- 过滤器：判断怪兽的召唤类型为特殊召唤，即该怪兽是通过特殊召唤出场的。
function c41855169.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动时目标判定：若场上有特殊召唤的怪兽，则将场上所有特殊召唤的怪兽作为破坏对象，并设置对应的破坏操作信息。
function c41855169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查场上是否存在特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有特殊召唤的怪兽，作为破坏对象的候选集合。
	local g=Duel.GetMatchingGroup(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将需要破坏的怪兽集合及其数量写入连锁的操作信息，用于其他卡片的时点/应对检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，破坏场上所有特殊召唤的怪兽。
function c41855169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得场上所有特殊召唤的怪兽，因为处理阶段怪兽可能会发生变化。
	local g=Duel.GetMatchingGroup(c41855169.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将这些怪兽全部破坏并送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
