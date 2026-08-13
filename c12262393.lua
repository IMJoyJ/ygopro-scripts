--磁石の戦士δ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只4星以下的「磁石战士」怪兽送去墓地。
-- ②：这张卡被送去墓地的场合，从自己墓地把「磁石战士δ」以外的3只4星以下的「磁石战士」怪兽除外才能发动。从手卡·卡组把1只「磁石战士 电磁武神」无视召唤条件特殊召唤。
function c12262393.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只4星以下的「磁石战士」怪兽送去墓地。
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
-- 定义①效果检索的卡的条件：必须是怪兽、卡名含有「磁石战士」字段、等级4以下且可以被送去墓地。
function c12262393.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- ①效果的发动条件判定与操作信息设置：卡组存在满足条件的「磁石战士」怪兽时才可发动；发动后设置将1只怪兽从卡组送去墓地的操作信息。
function c12262393.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认卡组中存在至少1只满足tgfilter条件的「磁石战士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c12262393.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将把1张卡从卡组送去墓地（用于连锁反应等判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家选择1张符合条件的「磁石战士」怪兽，将其从卡组送去墓地。
function c12262393.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组选择1张满足tgfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c12262393.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义②效果代价的除外卡的条件：必须是怪兽、卡名含有「磁石战士」字段、等级4以下、不是「磁石战士δ」本身且可作为代价除外。
function c12262393.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and not c:IsCode(12262393) and c:IsAbleToRemoveAsCost()
end
-- ②效果代价处理：检查墓地是否存在3只符合条件的「磁石战士」怪兽，存在则选择3只除外作为发动代价。
function c12262393.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认墓地存在至少3只满足cfilter条件的「磁石战士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c12262393.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 给玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择3张满足cfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c12262393.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的3张怪兽卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义可以特殊召唤的卡的筛选条件：卡号为75347539（「磁石战士 电磁武神」），且可以被效果特殊召唤（无视召唤条件但不无视苏生限制）。
function c12262393.spfilter(c,e,tp)
	return c:IsCode(75347539) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的目标条件与操作信息设置：需要自己主要怪兽区有空位且手卡·卡组存在可特殊召唤的「磁石战士 电磁武神」；满足后设置特殊召唤操作信息。
function c12262393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在1只满足spfilter条件的「磁石战士 电磁武神」。
		and Duel.IsExistingMatchingCard(c12262393.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将把1只怪兽从手卡·卡组特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：若场上已有空位，则玩家选择1只「磁石战士 电磁武神」，无视召唤条件特殊召唤到自己场上。
function c12262393.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，没有可用空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组选择1只满足spfilter条件的「磁石战士 电磁武神」。
	local g=Duel.SelectMatchingCard(tp,c12262393.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「磁石战士 电磁武神」以表侧表示特殊召唤到自己场上，无视召唤条件，但受苏生限制约束。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
