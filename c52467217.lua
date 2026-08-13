--牛頭鬼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地。
-- ②：这张卡被送去墓地的场合，从自己墓地把「牛头鬼」以外的1只不死族怪兽除外才能发动。从手卡把1只不死族怪兽特殊召唤。
function c52467217.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52467217,0))  --"卡组不死族怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52467217)
	e1:SetTarget(c52467217.tgtg)
	e1:SetOperation(c52467217.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，从自己墓地把「牛头鬼」以外的1只不死族怪兽除外才能发动。从手卡把1只不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52467217,1))  --"手卡不死族怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52467218)
	e2:SetCost(c52467217.spcost)
	e2:SetTarget(c52467217.sptg)
	e2:SetOperation(c52467217.spop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的卡：对象必须是不死族怪兽，且可以被送去墓地。
function c52467217.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- ①效果的目标处理函数：在发动时检查卡组是否存在满足条件的不死族怪兽；若存在，则登记把1张卡从卡组送去墓地的操作信息。
function c52467217.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认卡组中存在至少1只满足 tgfilter 的不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52467217.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果涉及送去墓地，预计将1张卡从自己的卡组送去墓地（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时的实际操作：从卡组选择1只不死族怪兽送去墓地，先提示选择再执行送墓。
function c52467217.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的卡组中选出1张满足 tgfilter（不死族且可送去墓地）的卡。
	local g=Duel.SelectMatchingCard(tp,c52467217.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果发动代价的筛选条件：对象是不死族怪兽，卡名不是「牛头鬼」，且可以作为代价除外。
function c52467217.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(52467217) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理：从自己墓地选择「牛头鬼」以外的1只不死族怪兽除外，作为特殊召唤效果发动的前提。
function c52467217.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己墓地存在至少1只满足 cfilter 的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52467217.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足 cfilter 的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c52467217.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果特殊召唤目标的筛选条件：手卡中的不死族怪兽，且可以被效果特殊召唤。
function c52467217.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标与发动条件检查：确认自己场上有空位且手卡存在可特殊召唤的不死族怪兽；并登记特殊召唤的操作信息。
function c52467217.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己的主要怪兽区域有空余格子可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中存在至少1只满足 spfilter 的不死族怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c52467217.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本效果涉及特殊召唤，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理时的实际操作：若自己场上仍有空位，则选择手卡1只不死族怪兽特殊召唤。
function c52467217.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区域有空位；若无空位则处理失败，不进行后续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足 spfilter（不死族且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c52467217.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
