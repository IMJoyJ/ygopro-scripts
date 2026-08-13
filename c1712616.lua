--騎甲虫空殺舞隊
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「骑甲虫」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，自己结束阶段从自己墓地把1只昆虫族怪兽除外才能发动。这张卡在自己场上盖放。
function c1712616.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「骑甲虫」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,1712616)
	e1:SetCondition(c1712616.condition)
	e1:SetTarget(c1712616.target)
	e1:SetOperation(c1712616.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，自己结束阶段从自己墓地把1只昆虫族怪兽除外才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,1712616)
	e2:SetCondition(c1712616.setcon)
	e2:SetCost(c1712616.setcost)
	e2:SetTarget(c1712616.settg)
	e2:SetOperation(c1712616.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断怪兽是否为表侧表示且属于「骑甲虫」系列，用于检查自己场上是否存在符合条件的骑甲虫怪兽。
function c1712616.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x170)
end
-- ①效果可发动的条件：该效果由对方发动且是怪兽效果、连锁可被无效，并且自己场上有表侧表示的「骑甲虫」怪兽。
function c1712616.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动者是对方，且发动的是怪兽效果，且该连锁能够被无效。
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 自己场上存在至少1只表侧表示的「骑甲虫」怪兽。
		and Duel.IsExistingMatchingCard(c1712616.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时判定阶段直接允许发动；登记要将对方的怪兽效果发动无效，并在怪兽可被破坏的情况下登记破坏信息。
function c1712616.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁上对方发动的怪兽效果（eg）登记为要被无效的对象，指定数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的怪兽能被效果破坏且仍然与效果相关，则登记将那只怪兽（eg）破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 实际处理：无效对方那只怪兽效果的发动，并将该效果对应的怪兽破坏。
function c1712616.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认无效成功，且发动效果的怪兽仍与这个效果相关（没有离场等原因导致不处理）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将eg中的那只怪兽破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤条件：判断怪兽是否为表侧表示、昆虫族且攻击力在3000以上，用于检查场上是否存在符合条件的昆虫族怪兽。
function c1712616.cfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttackAbove(3000)
end
-- ②效果可发动的条件：当前是自己的结束阶段，且自己场上有攻击力3000以上的表侧表示昆虫族怪兽。
function c1712616.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是自己，且自己场上存在至少1只攻击力3000以上的表侧表示昆虫族怪兽。
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c1712616.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中的怪兽是否为昆虫族且可以作为代价被除外，用于选择要除外的昆虫族怪兽。
function c1712616.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己墓地选择1只昆虫族怪兽除外；并提示玩家选择要除外的卡。
function c1712616.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己墓地是否存在至少1只符合条件的昆虫族怪兽作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c1712616.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示内容为“请选择要除外的卡”，供玩家选择要除外的墓地昆虫族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合条件的昆虫族怪兽。
	local g=Duel.SelectMatchingCard(tp,c1712616.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的昆虫族怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果发动时条件确认：墓地中的这张卡能够在场上盖放；登记这张卡将从墓地移动的操作信息。
function c1712616.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 登记这张卡以盖放形式从墓地离开的操作信息（涉及墓地相关效果判定）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果处理时实际动作：如果这张卡仍与效果相关，则将其盖放到自己的魔法陷阱区。
function c1712616.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍在墓地且与效果保持关联，然后将其在自己场上盖放。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
