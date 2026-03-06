--ワン・フォー・ワン
-- 效果：
-- ①：从手卡把1只怪兽送去墓地才能发动。从手卡·卡组把1只1星怪兽特殊召唤。
function c2295440.initial_effect(c)
	-- ①：从手卡把1只怪兽送去墓地才能发动。从手卡·卡组把1只1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2295440.cost)
	e1:SetTarget(c2295440.target)
	e1:SetOperation(c2295440.activate)
	c:RegisterEffect(e1)
end
-- 检查手卡中是否存在可以作为cost送去墓地的怪兽，并且手卡或卡组中存在1星怪兽可以特殊召唤
function c2295440.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查手卡或卡组中是否存在1星怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 检查怪兽是否为1星并且可以被特殊召唤
function c2295440.filter(c,e,tp)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置cost标签为1，表示需要支付cost
function c2295440.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 判断是否满足发动条件，若标签不为0则需要支付cost，否则只需确认是否有1星怪兽可特殊召唤
function c2295440.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否有足够的空间进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查手卡中是否存在可以作为cost送去墓地的怪兽
			return Duel.IsExistingMatchingCard(c2295440.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		else
			-- 检查手卡或卡组中是否存在1星怪兽可以特殊召唤
			return Duel.IsExistingMatchingCard(c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张可以作为cost送去墓地的怪兽
		local g=Duel.SelectMatchingCard(tp,c2295440.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽送去墓地作为cost
		Duel.SendtoGrave(g,REASON_COST)
	end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 发动效果，检查场上是否有空间并选择1只1星怪兽进行特殊召唤
function c2295440.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只1星怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c2295440.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的1星怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
