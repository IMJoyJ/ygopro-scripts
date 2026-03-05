--守護竜の核醒
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
function c11908584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11908584,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,11908584)
	e2:SetCost(c11908584.spcost)
	e2:SetTarget(c11908584.sptg)
	e2:SetOperation(c11908584.spop)
	c:RegisterEffect(e2)
end
-- 效果作用：定义用于判断是否可以作为发动代价的怪兽（效果怪兽）的过滤条件
function c11908584.costfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost()
end
-- 效果作用：检查玩家手牌是否存在满足条件的效果怪兽并将其丢弃作为发动代价
function c11908584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家手牌是否存在满足条件的效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11908584.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：从玩家手牌中丢弃一张满足条件的效果怪兽
	Duel.DiscardHand(tp,c11908584.costfilter,1,1,REASON_COST)
end
-- 效果作用：定义用于选择特殊召唤目标的过滤条件（通常龙族4星以下）
function c11908584.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：检查玩家场上是否有空位且手卡·卡组·墓地是否存在满足条件的怪兽
function c11908584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡·卡组·墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c11908584.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果作用：处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c11908584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：检查场地魔法是否还在场上且玩家场上是否有空位
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 效果作用：从手卡·卡组·墓地选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11908584.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
