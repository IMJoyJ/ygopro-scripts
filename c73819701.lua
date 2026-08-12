--白き竜の落胤
-- 效果：
-- 这个卡名在规则上当作「阿不思的落胤」使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从额外卡组把有「阿不思的落胤」的卡名记述的1只怪兽送去墓地才能发动。这张卡特殊召唤。这个回合，自己不是8星的融合·同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1只「艾克莉西娅」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含记录相关卡片、注册手牌特召效果（效果①）以及召唤·特殊召唤成功时特召「艾克莉西娅」怪兽的效果（效果②）。
function s.initial_effect(c)
	-- 在卡片中记录其效果文本中记述了「阿不思的落胤」（卡号68468459）。
	aux.AddCodeList(c,68468459)
	-- ①：这张卡在手卡存在的场合，从额外卡组把有「阿不思的落胤」的卡名记述的1只怪兽送去墓地才能发动。这张卡特殊召唤。这个回合，自己不是8星的融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1只「艾克莉西娅」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义用于发动代价的过滤函数，筛选有「阿不思的落胤」卡名记述的、可以作为代价送去墓地的怪兽卡。
function s.costfilter(c)
	-- 检查卡片是否记述了「阿不思的落胤」卡名、是否为怪兽卡，且能否作为代价送去墓地。
	return aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价处理，从额外卡组将1张满足条件的卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查额外卡组是否存在至少1张满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备与合法性检查，判断自己场上是否有空位且自身能否特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理，将自身特殊召唤，并对玩家施加本回合只能从额外卡组特殊召唤8星融合·同调怪兽的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是8星的融合·同调怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1只「艾克莉西娅」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制效果，作用于当前玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制的过滤函数，限制不能从额外卡组特殊召唤非8星的融合或同调怪兽。
function s.splimit(e,c)
	return not (c:IsType(TYPE_FUSION+TYPE_SYNCHRO) and c:IsLevel(8)) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义效果②的过滤函数，筛选「艾克莉西娅」系列且可以特殊召唤的怪兽。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1d7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查，判断自己场上是否有空位且手卡、卡组、墓地是否存在可特殊召唤的「艾克莉西娅」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手卡、卡组、墓地中是否存在至少1只满足条件的「艾克莉西娅」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，指定从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理，从手卡、卡组、墓地选择1只「艾克莉西娅」怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只满足条件且不受墓地限制影响的「艾克莉西娅」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
