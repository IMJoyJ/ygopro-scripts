--武装竜の霹靂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只3星「武装龙」怪兽守备表示特殊召唤。
function c34611551.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,34611551+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34611551.target)
	e1:SetOperation(c34611551.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的卡片组，包括等级为3、种族为武装龙且可以特殊召唤的怪兽。
function c34611551.filter(c,e,tp)
	return c:IsLevel(3) and c:IsSetCard(0x111) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：判断是否满足发动条件，包括场上存在空位和卡组中存在符合条件的怪兽。
function c34611551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查玩家卡组中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c34611551.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁处理信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：①：从卡组把1只3星「武装龙」怪兽守备表示特殊召唤。
function c34611551.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断玩家场上是否有可用的怪兽区域，如果没有则返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从卡组中选择满足条件的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,c34611551.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 效果作用：将选中的怪兽以守备表示形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
