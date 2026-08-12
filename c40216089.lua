--プラチナ・ガジェット
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的机械族怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只4星「零件」怪兽特殊召唤。
function c40216089.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，使用2个满足机械族条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(c40216089.linkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从手卡把1只4星以下的机械族怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40216089,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40216089)
	e2:SetTarget(c40216089.sptg1)
	e2:SetOperation(c40216089.spop1)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只4星「零件」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40216089,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,40216090)
	e3:SetCondition(c40216089.spcon2)
	e3:SetTarget(c40216089.sptg2)
	e3:SetOperation(c40216089.spop2)
	c:RegisterEffect(e3)
end
-- 连接素材条件：该卡在连接召唤的回合不能作为连接素材
function c40216089.linkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤手卡中满足机械族、4星以下且可特殊召唤的怪兽
function c40216089.spfilter1(c,e,tp,zone)
	return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置效果处理时的连锁信息，确定将要特殊召唤的怪兽数量和位置
function c40216089.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40216089.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽到手卡位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，从手卡选择满足条件的怪兽特殊召唤到场上
function c40216089.spop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c40216089.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 判断破坏原因是否为效果或战斗
function c40216089.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤卡组中满足零件系列、4星且可特殊召唤的怪兽
function c40216089.spfilter2(c,e,tp)
	return c:IsSetCard(0x51) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的连锁信息，确定将要特殊召唤的怪兽数量和位置
function c40216089.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c40216089.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽到卡组位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择满足条件的怪兽特殊召唤到场上
function c40216089.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c40216089.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
