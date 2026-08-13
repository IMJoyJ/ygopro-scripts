--プラチナ・ガジェット
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的机械族怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只4星「零件」怪兽特殊召唤。
function c40216089.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：必须以2只机械族怪兽作为连接素材才能进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(c40216089.linkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把1只4星以下的机械族怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40216089,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40216089)
	e2:SetTarget(c40216089.sptg1)
	e2:SetOperation(c40216089.spop1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只4星「零件」怪兽特殊召唤。
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
-- 效果条件判断：此卡在本回合被连接召唤（处于特殊召唤回合状态且召唤类型为连接召唤）时，返回真，用于触发“这张卡在连接召唤的回合不能作为连接素材”的限制。
function c40216089.linkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：筛选手卡中机械族且等级4以下、并能由本效果特殊召唤到指定连接区域（zone）的怪兽。
function c40216089.spfilter1(c,e,tp,zone)
	return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的发动条件与目标设定：获取此卡当前连接区域，若手卡中存在符合条件可特殊召唤到该区域的机械族4星以下怪兽，则登记从手卡特殊召唤1只怪兽的操作信息。
function c40216089.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 效果发动合法性检查（chk==0）：确认手卡中至少存在1只满足过滤条件（机械族、4星以下、可特殊召唤到连接区）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c40216089.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 登记操作信息：本次效果将把1只怪兽从手卡特殊召唤，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：确认连接区有空位后，让玩家从手卡选择1只符合条件的机械族4星以下怪兽，以表侧表示特殊召唤到这张卡所连接区的自己场上。
function c40216089.spop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查作为连接区的自己场上是否有可用怪兽区域；若没有可用空位，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选出1只满足条件（机械族、4星以下、可特殊召唤到连接区）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c40216089.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到这张卡所连接区的自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ②效果的发动条件：这张卡被破坏时，破坏原因必须为战斗或效果（bit.band与(REASON_EFFECT+REASON_BATTLE)不为0）才满足。
function c40216089.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤函数：筛选卡组中拥有「零件」字段、等级4、且能被本效果特殊召唤的怪兽。
function c40216089.spfilter2(c,e,tp)
	return c:IsSetCard(0x51) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与目标设定：确认己方怪兽区域有空位，且卡组中存在符合条件的4星「零件」怪兽，则登记从卡组特殊召唤1只怪兽的操作信息。
function c40216089.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0）：确认己方场上存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动合法性检查（chk==0）：确认卡组中存在至少1只符合条件的4星「零件」怪兽。
		and Duel.IsExistingMatchingCard(c40216089.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将把1只怪兽从卡组特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：确认场上有空位后，让玩家从卡组选择1只符合条件的4星「零件」怪兽，以表侧表示特殊召唤到自己场上。
function c40216089.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区域是否还有可用空位；若没有则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1只满足条件（4星「零件」字段且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c40216089.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
