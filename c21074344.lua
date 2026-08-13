--緑光の宣告者
-- 效果：
-- ①：对方把魔法卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c21074344.initial_effect(c)
	-- ①：对方把魔法卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
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
-- 判断是否满足发动条件：对方发动魔法卡（魔陷的卡片发动）且该连锁可以被无效，并且不是自己发动的。
function c21074344.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查该连锁是否可以被无效，以确保这个效果能够无效对方的魔法卡发动。
		and Duel.IsChainNegatable(ev)
end
-- 定义代价筛选条件：手牌中的天使族怪兽且可以作为代价送去墓地。
function c21074344.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 代价条件检查：判断这张卡自身是否可送去墓地，以及手牌是否存在1只满足条件的天使族怪兽，以确认能否支付代价。
function c21074344.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手牌中是否存在1只除这张卡自身以外的、可作为代价送入墓地的天使族怪兽。
		Duel.IsExistingMatchingCard(c21074344.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 给当前玩家显示“请选择要送去墓地的卡”的提示，让玩家选择作为代价的天使族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡选择1只满足代价筛选条件的天使族怪兽（不能选择这张卡自身）。
	local g=Duel.SelectMatchingCard(tp,c21074344.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的天使族怪兽和这张卡自身作为代价一起送去墓地，完成发动代价的支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时不取对象；登记无效的对象为对方发动的那个魔法卡连锁，并根据情况登记破坏信息。
function c21074344.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：要将对方发动的那个魔法卡连锁无效，目标为当前连锁涉及的卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方那张魔法卡可以被破坏且与效果有关联，则登记操作信息：要破坏该魔法卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时执行最终结果：先无效对方魔法卡的发动，成功后再将该魔法卡破坏。
function c21074344.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方魔法卡的发动，并且确认该魔法卡仍然与效果关联（没有被中途移走等）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动的魔法卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
