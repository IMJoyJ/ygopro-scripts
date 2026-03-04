--磁石の戦士δ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只4星以下的「磁石战士」怪兽送去墓地。
-- ②：这张卡被送去墓地的场合，从自己墓地把「磁石战士δ」以外的3只4星以下的「磁石战士」怪兽除外才能发动。从手卡·卡组把1只「磁石战士 电磁武神」无视召唤条件特殊召唤。
function c12262393.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只4星以下的「磁石战士」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12262393,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,12262393)
	e1:SetTarget(c12262393.tgtg)
	e1:SetOperation(c12262393.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，从自己墓地把「磁石战士δ」以外的3只4星以下的「磁石战士」怪兽除外才能发动。从手卡·卡组把1只「磁石战士 电磁武神」无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12262393,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,12262394)
	e3:SetCost(c12262393.spcost)
	e3:SetTarget(c12262393.sptg)
	e3:SetOperation(c12262393.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「磁石战士」怪兽（4星以下）
function c12262393.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 效果处理时的处理函数，用于设置效果目标
function c12262393.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12262393.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的处理函数，用于执行效果
function c12262393.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12262393.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选满足条件的「磁石战士」怪兽（4星以下，非δ）
function c12262393.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and not c:IsCode(12262393) and c:IsAbleToRemoveAsCost()
end
-- 效果处理时的处理函数，用于设置效果发动的代价
function c12262393.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：墓地中是否存在3张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12262393.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 从墓地中选择3张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12262393.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选「磁石战士 电磁武神」怪兽
function c12262393.spfilter(c,e,tp)
	return c:IsCode(75347539) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果处理时的处理函数，用于设置效果目标
function c12262393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上是否有空位且手卡/卡组中存在「磁石战士 电磁武神」
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续判断是否满足发动条件：手卡/卡组中是否存在「磁石战士 电磁武神」
		and Duel.IsExistingMatchingCard(c12262393.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：将1张「磁石战士 电磁武神」从手卡或卡组特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理时的处理函数，用于执行效果
function c12262393.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡或卡组中选择1张「磁石战士 电磁武神」
	local g=Duel.SelectMatchingCard(tp,c12262393.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「磁石战士 电磁武神」特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
