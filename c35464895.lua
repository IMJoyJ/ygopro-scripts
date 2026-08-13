--デステニー・シグナル
-- 效果：
-- 自己场上的怪兽被战斗破坏送去墓地时才能发动。从自己的手卡·卡组特殊召唤1只名字带有「命运英雄」的4星以下的怪兽。
function c35464895.initial_effect(c)
	-- 自己场上的怪兽被战斗破坏送去墓地时才能发动。从自己的手卡·卡组特殊召唤1只名字带有「命运英雄」的4星以下的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c35464895.condition)
	e1:SetTarget(c35464895.target)
	e1:SetOperation(c35464895.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：怪兽被战斗破坏且被送去墓地，且其之前控制者为发动玩家。
function c35464895.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 满足条件：被战斗破坏送去墓地的怪兽中有至少1只属于己方控制。
function c35464895.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35464895.cfilter,1,nil,tp)
end
-- 特殊召唤候选：等级4以下、名字带有「命运英雄」、且能够被特殊召唤的怪兽。
function c35464895.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标确认：自己主要怪兽区有空位，且手卡或卡组存在符合条件的怪兽。
function c35464895.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在满足特殊召唤条件的「命运英雄」4星以下怪兽。
		and Duel.IsExistingMatchingCard(c35464895.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理特殊召唤：选择1只符合条件的怪兽以表侧表示特殊召唤。
function c35464895.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区仍有空位，否则效果终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示操作者选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选出1只符合条件的「命运英雄」4星以下怪兽。
	local g=Duel.SelectMatchingCard(tp,c35464895.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
