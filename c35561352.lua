--セフィラの神撃
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，从自己的额外卡组把1只表侧表示的「神数」怪兽除外才能发动。那个发动无效并破坏。
function c35561352.initial_effect(c)
	-- 创建效果，设置效果分类为使发动无效和破坏，效果类型为发动，效果代码为连锁时，条件为c35561352.condition，代价为c35561352.cost，目标为c35561352.target，效果处理为c35561352.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c35561352.condition)
	e1:SetCost(c35561352.cost)
	e1:SetTarget(c35561352.target)
	e1:SetOperation(c35561352.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选表侧表示的神数怪兽且可以作为除外的代价
function c35561352.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4) and c:IsAbleToRemoveAsCost()
end
-- 效果发动条件，判断是否为怪兽效果或魔法·陷阱卡发动且该连锁可以被无效
function c35561352.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的连锁是否为怪兽效果或魔法·陷阱卡发动且该连锁可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 效果代价处理，检查是否满足除外1只表侧表示的神数怪兽的条件，若满足则提示选择并除外该怪兽
function c35561352.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外1只表侧表示的神数怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c35561352.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只表侧表示的神数怪兽
	local g=Duel.SelectMatchingCard(tp,c35561352.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和可能的破坏
function c35561352.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使发动无效并破坏对应卡片
function c35561352.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且对应卡片仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
