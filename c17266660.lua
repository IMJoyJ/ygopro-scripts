--朱光の宣告者
-- 效果：
-- ①：对方把怪兽的效果发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c17266660.initial_effect(c)
	-- 创建效果怪兽的效果的发动无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17266660,0))  --"效果怪兽的效果的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17266660.discon)
	e1:SetCost(c17266660.discost)
	e1:SetTarget(c17266660.distg)
	e1:SetOperation(c17266660.disop)
	c:RegisterEffect(e1)
end
-- 对方把怪兽的效果发动时才能发动
function c17266660.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方把怪兽的效果发动时才能发动
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于检索满足条件的天使族怪兽
function c17266660.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 设置发动时的费用，需要支付手卡的这张卡和1只天使族怪兽
function c17266660.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手卡是否存在至少1只满足条件的天使族怪兽
		Duel.IsExistingMatchingCard(c17266660.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c17266660.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏
function c17266660.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的效果分类
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果分类
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理效果的发动，使发动无效并破坏
function c17266660.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使发动无效并检查效果是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方的怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
