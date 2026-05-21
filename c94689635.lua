--紫光の宣告者
-- 效果：
-- ①：对方把陷阱卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c94689635.initial_effect(c)
	-- ①：对方把陷阱卡发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94689635,0))  --"对方的陷阱卡的发动无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94689635.discon)
	e1:SetCost(c94689635.discost)
	e1:SetTarget(c94689635.distg)
	e1:SetOperation(c94689635.disop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：对方发动了陷阱卡（卡片的发动），且该发动可以被无效
function c94689635.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 过滤条件：手卡中除自身以外的天使族怪兽，且能作为代价送去墓地
function c94689635.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 判断发动代价：自身能作为代价送去墓地，且手卡中存在至少1只其他满足条件的天使族怪兽
function c94689635.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手卡中是否存在除自身以外的、可以作为代价送去墓地的天使族怪兽
		Duel.IsExistingMatchingCard(c94689635.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只除自身以外的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c94689635.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将这张卡和选择的天使族怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理的目标：确立无效发动与破坏的操作信息
function c94689635.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍与效果关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c94689635.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
