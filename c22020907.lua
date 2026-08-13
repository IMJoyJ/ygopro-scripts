--ヒーロー・シグナル
-- 效果：
-- ①：自己场上的怪兽被战斗破坏送去墓地时才能发动。从手卡·卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
function c22020907.initial_effect(c)
	-- ①：自己场上的怪兽被战斗破坏送去墓地时才能发动。从手卡·卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22020907.condition)
	e1:SetTarget(c22020907.target)
	e1:SetOperation(c22020907.operation)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否因战斗被破坏、目前位于墓地且原控制者为自己，用于筛选我方被战破的怪兽。
function c22020907.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 检查本次战斗破坏的怪兽群中是否存在至少1只满足条件的我方怪兽，作为效果发动的触发条件。
function c22020907.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22020907.cfilter,1,nil,tp)
end
-- 特殊召唤候选条件：等级4以下、属于「元素英雄」字段、且可以被特殊召唤。
function c22020907.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时进行合法性检查：确认自己怪兽区有空位，且手卡或卡组存在符合条件的「元素英雄」怪兽；若通过则设置特殊召唤的操作信息。
function c22020907.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己场上是否有可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡或卡组中是否存在1只满足特殊召唤条件的「元素英雄」怪兽。
		and Duel.IsExistingMatchingCard(c22020907.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理时：选择1只符合条件的「元素英雄」怪兽从手卡·卡组特殊召唤。
function c22020907.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用怪兽区域则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1只满足条件的「元素英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c22020907.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
