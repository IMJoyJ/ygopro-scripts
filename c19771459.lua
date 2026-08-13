--ウォークライ・ガトス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有战士族·地属性怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
function c19771459.initial_effect(c)
	-- ①：自己场上有战士族·地属性怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19771459,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19771459.spcon1)
	e1:SetTarget(c19771459.sptg1)
	e1:SetOperation(c19771459.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19771459,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,19771459)
	e2:SetCondition(c19771459.spcon2)
	e2:SetTarget(c19771459.sptg2)
	e2:SetOperation(c19771459.spop2)
	c:RegisterEffect(e2)
end
-- 筛选函数：判断召唤成功的怪兽是否为表侧表示、地属性、战士族且为我方控制。
function c19771459.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsControler(tp)
end
-- ①效果发动条件：本次召唤成功的怪兽组中存在至少1只满足上述筛选条件的怪兽。
function c19771459.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19771459.cfilter,1,nil,tp)
end
-- ①效果的发动目标判定：自己主要怪兽区有空位，且这张卡本身能够被特殊召唤，满足条件才能发动。
function c19771459.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余格子，避免无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作信息为特殊召唤这张卡，用于后续效果检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果保持关联（未离场或未失去目标），则将这张卡特殊召唤。
function c19771459.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示形式特殊召唤到自己场上，不检查召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果发动条件：这张卡是被对方玩家的效果从怪兽区域送去墓地，且原本控制者为自己、之前位于怪兽区域、送去墓地的原因为效果。
function c19771459.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 特殊召唤候选卡筛选：等级5以上、持有「战吼」（0x15f）字段、并且能够被当前效果特殊召唤。
function c19771459.spfilter2(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动目标判定：自己主要怪兽区有空位，且手卡·卡组中存在至少1张满足筛选条件的怪兽。
function c19771459.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余格子，防止无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查从手卡·卡组中是否存在至少1张满足筛选条件的可特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(c19771459.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次操作信息：从手卡·卡组进行1只怪兽的特殊召唤，用于效果检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：若场上没有空位则直接结束；否则提示玩家选择要特殊召唤的卡，从手卡·卡组中选出1张符合条件的怪兽并特殊召唤。
function c19771459.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己主要怪兽区没有空余格子，则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，供玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组中选出1张满足 spfilter2 条件的「战吼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c19771459.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
