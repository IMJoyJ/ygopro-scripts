--ヒーロー・シグナル
-- 效果：
-- ①：自己场上的怪兽被战斗破坏送去墓地时才能发动。从手卡·卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
function c22020907.initial_effect(c)
	-- 效果原文内容：①：自己场上的怪兽被战斗破坏送去墓地时才能发动。从手卡·卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22020907.condition)
	e1:SetTarget(c22020907.target)
	e1:SetOperation(c22020907.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查目标怪兽是否因战斗破坏被送入墓地且之前属于玩家控制
function c22020907.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 规则层面作用：判断是否有满足条件的怪兽被战斗破坏送入墓地
function c22020907.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22020907.cfilter,1,nil,tp)
end
-- 规则层面作用：筛选4星以下且为「元素英雄」的怪兽，且可以被特殊召唤
function c22020907.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件，包括场上是否有空位以及手卡/卡组是否存在符合条件的怪兽
function c22020907.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c22020907.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁处理信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 规则层面作用：执行效果处理，包括检查场上空位、选择怪兽并进行特殊召唤
function c22020907.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：若场上无空位则直接返回不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：让玩家从手卡或卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c22020907.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 规则层面作用：将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
