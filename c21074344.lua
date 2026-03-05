--緑光の宣告者
-- 效果：
-- ①：对方把魔法卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c21074344.initial_effect(c)
	-- 效果原文内容：①：对方把魔法卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21074344,0))  --"对方的魔法卡的发动无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c21074344.discon)
	e1:SetCost(c21074344.discost)
	e1:SetTarget(c21074344.distg)
	e1:SetOperation(c21074344.disop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方发动的魔法卡且可以被无效
function c21074344.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 效果作用：检查连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果作用：过滤函数，用于筛选手卡中满足条件的天使族怪兽
function c21074344.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 效果作用：判断是否满足发动条件，即手卡有这张卡和至少1只天使族怪兽
function c21074344.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 效果作用：检查手卡是否存在至少1只天使族怪兽
		Duel.IsExistingMatchingCard(c21074344.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c21074344.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 效果作用：将选择的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用：设置连锁操作信息，包括使发动无效和破坏
function c21074344.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行效果处理，使发动无效并破坏
function c21074344.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否成功使发动无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：破坏目标魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
