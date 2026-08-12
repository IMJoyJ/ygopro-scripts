--幽鬼うさぎ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：场上的怪兽的效果发动时或者场上的已是表侧表示存在的魔法·陷阱卡的效果发动时，把手卡·场上的这张卡送去墓地才能发动。场上的那张卡破坏。
function c59438930.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：场上的怪兽的效果发动时或者场上的已是表侧表示存在的魔法·陷阱卡的效果发动时，把手卡·场上的这张卡送去墓地才能发动。场上的那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,59438930)
	e1:SetCondition(c59438930.condition)
	e1:SetCost(c59438930.cost)
	e1:SetTarget(c59438930.target)
	e1:SetOperation(c59438930.operation)
	c:RegisterEffect(e1)
end
-- 检查发动效果的卡是否在场上且与该效果有关联，并确认该效果是怪兽效果发动，或者是已在场上表侧表示存在的魔法·陷阱卡的效果发动
function c59438930.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and (re:IsActiveType(TYPE_MONSTER)
		or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
-- 检查自身是否能作为代价送去墓地，并在发动时将自身送去墓地
function c59438930.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡或场上的这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检查发动效果的卡是否可以被破坏，并设置破坏该卡的操作信息
function c59438930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置将发动效果的那张卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理：若发动效果的卡仍与该效果有关联，则将其破坏
function c59438930.operation(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的那张卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
