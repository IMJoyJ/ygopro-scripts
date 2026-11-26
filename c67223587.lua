--ハンディキャップマッチ！
-- 效果：
-- 自己把名字带有「剑斗兽」的怪兽的特殊召唤成功时才能发动。从自己的手卡·卡组把1只名字带有「剑斗兽」的4星以下的怪兽特殊召唤。
function c67223587.initial_effect(c)
	-- 自己把名字带有「剑斗兽」的怪兽的特殊召唤成功时才能发动。从自己的手卡·卡组把1只名字带有「剑斗兽」的4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c67223587.condition)
	e1:SetTarget(c67223587.target)
	e1:SetOperation(c67223587.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查怪兽是否为表侧表示、由己方特殊召唤且卡名带有「剑斗兽」
function c67223587.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x1019)
end
-- 发动条件检查：确认本次特殊召唤成功的怪兽中存在由己方特殊召唤的「剑斗兽」怪兽
function c67223587.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c67223587.cfilter,1,nil,tp)
end
-- 筛选条件：检查卡片是否为4星以下、卡名带有「剑斗兽」且可特殊召唤的怪兽
function c67223587.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动检测：确认己方怪兽区有空位且己方手卡·卡组存在满足条件的「剑斗兽」怪兽
function c67223587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方主要怪兽区存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查（后半）：确认己方手卡·卡组存在至少1只4星以下可特殊召唤的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c67223587.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理流程：确认己方怪兽区有空位后，从己方手卡·卡组选1只4星以下「剑斗兽」怪兽特殊召唤
function c67223587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否有空位，若无空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从己方手卡·卡组选择1只4星以下「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c67223587.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选「剑斗兽」怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
