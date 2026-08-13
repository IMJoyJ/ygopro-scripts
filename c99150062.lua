--ナチュル・アントジョー
-- 效果：
-- 对方对怪兽的特殊召唤成功时，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽特殊召唤。
function c99150062.initial_effect(c)
	-- 对方对怪兽的特殊召唤成功时，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99150062,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c99150062.spcon)
	e1:SetTarget(c99150062.sptg)
	e1:SetOperation(c99150062.spop)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断特殊召唤成功的怪兽是否由对方玩家（1-tp）特殊召唤。
function c99150062.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 特殊召唤成功时点判定：若刚被特殊召唤的怪兽群中存在至少1只由对方玩家特殊召唤的怪兽，则满足本卡的发动条件。
function c99150062.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99150062.cfilter,1,nil,tp)
end
-- 筛选可特殊召唤的候选怪兽：必须为名字带有「自然」、等级3以下，且可以被该效果正常特殊召唤（不忽略召唤条件与苏生限制）的怪兽。
function c99150062.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标检查和条件判定（chk==0即发动前检查）：要求自己主要怪兽区有空位且卡组中存在符合条件的「自然」怪兽。
function c99150062.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1张满足筛选条件的「自然」怪兽。
		and Duel.IsExistingMatchingCard(c99150062.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果涉及特殊召唤，预定从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际操作：确认空位后，从卡组选择1只符合条件的「自然」怪兽特殊召唤到自己场上。
function c99150062.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空格，若无则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组筛选并选择1张符合条件的「自然」怪兽。
	local g=Duel.SelectMatchingCard(tp,c99150062.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
