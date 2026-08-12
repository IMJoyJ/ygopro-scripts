--ドラゴンメイド・エルデ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只2星「半龙女仆」怪兽特殊召唤。
function c76782778.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76782778,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,76782778)
	e1:SetCost(c76782778.spcost1)
	e1:SetTarget(c76782778.sptg1)
	e1:SetOperation(c76782778.spop1)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c76782778.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只2星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76782778,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,76782779)
	e3:SetTarget(c76782778.sptg2)
	e3:SetOperation(c76782778.spop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价（Cost）函数
function c76782778.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡丢弃送去墓地，作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果的过滤条件：手卡中4星以下的「半龙女仆」怪兽
function c76782778.spfilter1(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（Target）函数
function c76782778.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的4星以下「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c76782778.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理（Operation）函数
function c76782778.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的4星以下「半龙女仆」怪兽
	local g=Duel.SelectMatchingCard(tp,c76782778.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的过滤条件：场上表侧表示的融合怪兽
function c76782778.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ②效果的适用条件函数
function c76782778.indcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的融合怪兽
	return Duel.IsExistingMatchingCard(c76782778.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ③效果的过滤条件：手卡中2星的「半龙女仆」怪兽
function c76782778.spfilter2(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备（Target）函数
function c76782778.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查这张卡离开场上后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的2星「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c76782778.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置将这张卡送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置特殊召唤的操作信息，预计从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果的效果处理（Operation）函数
function c76782778.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于场上，则将其送回持有者手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡已成功回到手卡，且自己场上有可用的怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1只满足条件的2星「半龙女仆」怪兽
		local g=Duel.SelectMatchingCard(tp,c76782778.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
