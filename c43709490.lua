--被検体ミュートリアGB－88
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的场地区域有「秘异三变体进化研究所」存在的场合，对方主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：对方回合，这张卡特殊召唤成功的场合，把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只8星「秘异三变」怪兽特殊召唤。
function c43709490.initial_effect(c)
	-- 将卡名「秘异三变体进化研究所」（代码34572613）记录为这张卡效果文中所记载的卡名。
	aux.AddCodeList(c,34572613)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己的场地区域有「秘异三变体进化研究所」存在的场合，对方主要阶段才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43709490,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43709490)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c43709490.spcon)
	e1:SetTarget(c43709490.sptg)
	e1:SetOperation(c43709490.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，这张卡特殊召唤成功的场合，把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只8星「秘异三变」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43709490,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,43709491)
	e2:SetCondition(c43709490.sp2con)
	e2:SetCost(c43709490.sp2cost)
	e2:SetTarget(c43709490.sp2tg)
	e2:SetOperation(c43709490.sp2op)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件函数：判断是否满足自己场地区域存在「秘异三变体进化研究所」，且当前为对方主要阶段。
function c43709490.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场地区域是否有「秘异三变体进化研究所」，并且当前回合玩家不是自己（即对方回合）。
	return Duel.IsEnvironment(34572613,tp,LOCATION_FZONE) and Duel.GetTurnPlayer()~=tp
		-- 且当前阶段为主要阶段1或主要阶段2。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ①效果的发动合法判定：这张卡可以被特殊召唤，并且自己场上有空余的怪兽区。
function c43709490.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己场上存在可用的怪兽区空格。
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置操作信息，声明本效果将特殊召唤这张卡，数量为1，供连锁检测与效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理函数：若这张卡仍与效果关联，则将其特殊召唤；否则不处理。
function c43709490.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件函数：仅在对方回合（当前回合玩家不是自己）时满足。
function c43709490.sp2con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己，即对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果cost候选卡的过滤条件：该卡可作为cost被除外，且是手卡或自己场上的表侧表示卡；并且将该卡与这张卡一同处理后，自己场上仍有可用怪兽区。
function c43709490.sp2costfilter(c,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		-- 把候选卡和这张卡作为预离场对象，检查处理后自己场上是否仍有可用怪兽区空格。
		and Duel.GetMZoneCount(tp,tg)>0
end
-- ②效果的cost条件判定（chk==0）：此卡必须可解放，并且手卡或自己场上存在满足条件的可除外卡。
function c43709490.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		-- 确认手卡或自己场上存在至少1张满足sp2costfilter条件的卡（排除这张卡自身）。
		and Duel.IsExistingMatchingCard(c43709490.sp2costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp,c) end
	-- 解放这张卡作为发动代价。
	Duel.Release(c,REASON_COST)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡或自己场上选择1张满足条件的卡作为除外的cost。
	local cost=Duel.SelectMatchingCard(tp,c43709490.sp2costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,tp,c)
	-- 将选中的卡表侧除外，完成发动代价。
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- ②效果可特殊召唤的怪兽过滤条件：该怪兽是8星「秘异三变」怪兽，可以被特殊召唤，并且是墓地中的怪兽或表侧除外的自己的怪兽。
function c43709490.sp2tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsSetCard(0x157) and c:IsLevel(8) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- ②效果的发动判定与操作信息设置：墓地或除外区存在符合条件的怪兽时，可发动，并设置特殊召唤操作信息。
function c43709490.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或除外区是否存在至少1只满足特殊召唤条件的「秘异三变」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c43709490.sp2tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只来自自己墓地或除外区的「秘异三变」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理函数：从自己墓地或除外的自己的怪兽中选1只8星「秘异三变」怪兽特殊召唤。
function c43709490.sp2op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区，否则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地或除外区选择1只符合条件的「秘异三变」怪兽（应用王家长眠之谷效果滤镜）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c43709490.sp2tgfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 若选择成功，将那只怪兽表侧表示特殊召唤到自己场上。
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
