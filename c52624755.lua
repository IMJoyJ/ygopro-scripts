--闇・道化師のペーテン
-- 效果：
-- ①：这张卡被送去墓地时，把墓地的这张卡除外才能发动。从手卡·卡组把1只「暗道化师 彼得」特殊召唤。
function c52624755.initial_effect(c)
	-- ①：这张卡被送去墓地时，把墓地的这张卡除外才能发动。从手卡·卡组把1只「暗道化师 彼得」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52624755,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCost(c52624755.cost)
	e1:SetTarget(c52624755.target)
	e1:SetOperation(c52624755.operation)
	c:RegisterEffect(e1)
end
-- 代价处理函数：先检查这张卡是否可作为代价除外，若可以则将其从墓地除外作为发动代价。
function c52624755.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示从墓地除外，作为效果发动的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：候选卡必须是卡名「暗道化师 彼得」，且能够被当前效果特殊召唤。
function c52624755.filter(c,e,sp)
	return c:IsCode(52624755) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动条件判定：自己主要怪兽区有空位，且手卡·卡组中存在满足条件的「暗道化师 彼得」时才可发动。
function c52624755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足特殊召唤条件的「暗道化师 彼得」。
		and Duel.IsExistingMatchingCard(c52624755.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本次效果将从手卡·卡组特殊召唤1只「暗道化师 彼得」，用于相关卡片和时点的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数：再次确认有空位后，从手卡·卡组选择1只「暗道化师 彼得」特殊召唤。
function c52624755.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用的主要怪兽区空格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只符合过滤条件的「暗道化师 彼得」。
	local g=Duel.SelectMatchingCard(tp,c52624755.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「暗道化师 彼得」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
