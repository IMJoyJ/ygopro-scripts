--デステニー・シグナル
-- 效果：
-- 自己场上的怪兽被战斗破坏送去墓地时才能发动。从自己的手卡·卡组特殊召唤1只名字带有「命运英雄」的4星以下的怪兽。
function c35464895.initial_effect(c)
	-- 效果原文内容：自己场上的怪兽被战斗破坏送去墓地时才能发动。从自己的手卡·卡组特殊召唤1只名字带有「命运英雄」的4星以下的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c35464895.condition)
	e1:SetTarget(c35464895.target)
	e1:SetOperation(c35464895.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查目标怪兽是否因战斗破坏而送入墓地且之前属于玩家控制
function c35464895.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 规则层面作用：判断是否有满足条件的怪兽被战斗破坏送入墓地
function c35464895.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35464895.cfilter,1,nil,tp)
end
-- 规则层面作用：筛选名字带有「命运英雄」且等级4以下可特殊召唤的怪兽
function c35464895.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件，包括场上是否有空位及手卡/卡组是否存在符合条件的怪兽
function c35464895.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c35464895.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁处理信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果原文内容：自己场上的怪兽被战斗破坏送去墓地时才能发动。从自己的手卡·卡组特殊召唤1只名字带有「命运英雄」的4星以下的怪兽。
function c35464895.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：若场上无空位则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的1只怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c35464895.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 规则层面作用：将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
