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
-- 检查是否满足费用条件，即自身可以作为除外费用
function c52624755.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从游戏中除外作为发动费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 用于筛选符合条件的「暗道化师 彼得」卡片
function c52624755.filter(c,e,sp)
	return c:IsCode(52624755) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 判断是否满足发动条件，即场上有空位且手卡或卡组存在「暗道化师 彼得」
function c52624755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡或卡组中是否存在至少1张「暗道化师 彼得」
		and Duel.IsExistingMatchingCard(c52624755.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表明此效果会特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行效果的处理流程，包括选择目标并进行特殊召唤
function c52624755.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否有空位以避免无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择一张「暗道化师 彼得」作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,c52624755.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
