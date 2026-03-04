--守護竜の核醒
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
function c11908584.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
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
-- 过滤函数，用于判断手卡中是否包含效果怪兽且可以作为代价送去墓地
function c11908584.costfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用处理函数，用于检查并丢弃手卡中的1只效果怪兽
function c11908584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少1张满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11908584.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中选择并丢弃1张满足costfilter条件的卡作为发动代价
	Duel.DiscardHand(tp,c11908584.costfilter,1,1,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的4星以下龙族通常怪兽
function c11908584.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理函数，用于确认是否可以发动效果
function c11908584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡·卡组·墓地中是否存在至少1张满足spfilter条件的卡
		and Duel.IsExistingMatchingCard(c11908584.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，用于执行特殊召唤操作
function c11908584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查效果是否仍然有效且玩家场上存在可用区域
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从玩家手卡·卡组·墓地中选择1张满足spfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11908584.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以守备表示特殊召唤到玩家场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
