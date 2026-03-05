--騎甲虫空殺舞隊
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「骑甲虫」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，自己结束阶段从自己墓地把1只昆虫族怪兽除外才能发动。这张卡在自己场上盖放。
function c1712616.initial_effect(c)
	-- ①：自己场上有「骑甲虫」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,1712616)
	e1:SetCondition(c1712616.condition)
	e1:SetTarget(c1712616.target)
	e1:SetOperation(c1712616.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，自己结束阶段从自己墓地把1只昆虫族怪兽除外才能发动。这张卡在自己场上盖放。
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
-- 过滤函数，检查场上是否存在「骑甲虫」怪兽
function c1712616.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x170)
end
-- 效果条件函数，判断是否满足①效果的发动条件
function c1712616.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方怪兽效果发动且该连锁可以被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 判断自己场上是否存在「骑甲虫」怪兽
		and Duel.IsExistingMatchingCard(c1712616.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，设置效果处理时要无效和破坏的卡
function c1712616.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理时要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应卡
function c1712616.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且对应卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数，检查场上是否存在攻击力3000以上的昆虫族怪兽
function c1712616.cfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttackAbove(3000)
end
-- 效果条件函数，判断是否满足②效果的发动条件
function c1712616.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前为己方回合且己方场上存在攻击力3000以上的昆虫族怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c1712616.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查墓地中是否存在昆虫族怪兽
function c1712616.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，设置②效果的发动代价
function c1712616.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在满足条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1712616.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c1712616.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果目标函数，设置②效果发动时要盖放的卡
function c1712616.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置效果处理时要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果处理函数，将卡在己方场上盖放
function c1712616.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否有效且能进行盖放操作
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
