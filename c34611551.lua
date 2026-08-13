--武装竜の霹靂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只3星「武装龙」怪兽守备表示特殊召唤。
function c34611551.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只3星「武装龙」怪兽守备表示特殊召唤。
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
-- 筛选函数：判定卡是否为3星、属于「武装龙」字段，且能够被效果以表侧守备表示特殊召唤。
function c34611551.filter(c,e,tp)
	return c:IsLevel(3) and c:IsSetCard(0x111) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的目标判定函数：在效果发动合法性检查时，确认自己主要怪兽区有空位，并且卡组中存在符合filter条件的1只「武装龙」怪兽。
function c34611551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上主要怪兽区域存在空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查（续）：确认卡组中存在至少1张满足filter条件（3星、武装龙字段、可表侧守备特殊召唤）的卡。
		and Duel.IsExistingMatchingCard(c34611551.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将进行特殊召唤，预计从卡组特殊召唤1只怪兽（对象持有者为自己，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若主要怪兽区仍有空位，则让玩家选择卡组中1只符合条件的怪兽，并以其表侧守备表示特殊召唤到自己场上。
function c34611551.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查：若自己主要怪兽区没有空位，则终止处理（不进行特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选择1张满足filter条件的卡（过滤条件同filter函数）。
	local g=Duel.SelectMatchingCard(tp,c34611551.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
