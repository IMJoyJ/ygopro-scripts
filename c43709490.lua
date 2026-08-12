--被検体ミュートリアGB－88
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的场地区域有「秘异三变体进化研究所」存在的场合，对方主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：对方回合，这张卡特殊召唤成功的场合，把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只8星「秘异三变」怪兽特殊召唤。
function c43709490.initial_effect(c)
	-- 注册此卡与「秘异三变体进化研究所」的关联
	aux.AddCodeList(c,34572613)
	-- ①：自己的场地区域有「秘异三变体进化研究所」存在的场合，对方主要阶段才能发动。这张卡从手卡特殊召唤。
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
-- 判断是否满足①效果的发动条件：场地区域存在「秘异三变体进化研究所」且当前为对方回合
function c43709490.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足①效果的发动条件：场地区域存在「秘异三变体进化研究所」且当前为对方回合
	return Duel.IsEnvironment(34572613,tp,LOCATION_FZONE) and Duel.GetTurnPlayer()~=tp
		-- 判断是否满足①效果的发动条件：当前处于主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 设置①效果的目标：检查此卡是否能特殊召唤且场上存在空怪兽区
function c43709490.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 设置①效果的目标：检查此卡是否能特殊召唤且场上存在空怪兽区
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置①效果的处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行①效果的处理：将此卡特殊召唤
function c43709490.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行①效果的处理：将此卡特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否满足②效果的发动条件：当前为对方回合
function c43709490.sp2con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足②效果的发动条件：当前为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 定义②效果发动时的除外卡筛选条件：可除外手牌或场上表侧表示的卡，并确保有空怪兽区
function c43709490.sp2costfilter(c,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		-- 定义②效果发动时的除外卡筛选条件：可除外手牌或场上表侧表示的卡，并确保有空怪兽区
		and Duel.GetMZoneCount(tp,tg)>0
end
-- 设置②效果的发动条件：检查此卡是否能解放且场上有满足条件的除外卡
function c43709490.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		-- 设置②效果的发动条件：检查此卡是否能解放且场上有满足条件的除外卡
		and Duel.IsExistingMatchingCard(c43709490.sp2costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp,c) end
	-- 将此卡解放作为②效果的发动费用
	Duel.Release(c,REASON_COST)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的除外卡
	local cost=Duel.SelectMatchingCard(tp,c43709490.sp2costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,tp,c)
	-- 将所选卡除外作为②效果的发动费用
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- 定义②效果中特殊召唤的怪兽筛选条件：必须是8星「秘异三变」怪兽且处于墓地或除外状态
function c43709490.sp2tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsSetCard(0x157) and c:IsLevel(8) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 设置②效果的目标：检查墓地或除外区是否存在满足条件的怪兽
function c43709490.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置②效果的目标：检查墓地或除外区是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43709490.sp2tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置②效果的处理信息：从墓地或除外区特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 执行②效果的处理：选择并特殊召唤一只满足条件的怪兽
function c43709490.sp2op(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c43709490.sp2tgfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 执行②效果的处理：将所选怪兽特殊召唤
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
