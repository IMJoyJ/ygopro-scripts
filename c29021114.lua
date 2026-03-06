--シルバー・ガジェット
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只机械族·4星怪兽特殊召唤。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「银色零件」以外的1只4星「零件」怪兽特殊召唤。
function c29021114.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只机械族·4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29021114,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,29021114)
	e1:SetTarget(c29021114.sptg1)
	e1:SetOperation(c29021114.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「银色零件」以外的1只4星「零件」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29021114,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,29021114)
	e3:SetCondition(c29021114.spcon2)
	e3:SetTarget(c29021114.sptg2)
	e3:SetOperation(c29021114.spop2)
	c:RegisterEffect(e3)
end
-- 效果过滤函数，用于筛选手卡中满足条件的机械族4星怪兽
function c29021114.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判定函数，判断是否满足发动条件
function c29021114.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手卡中是否存在满足条件的机械族4星怪兽
		and Duel.IsExistingMatchingCard(c29021114.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤操作
function c29021114.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c29021114.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件函数，判断该卡是否因战斗或效果而被破坏
function c29021114.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果过滤函数，用于筛选卡组中满足条件的4星零件怪兽（非银色零件）
function c29021114.spfilter2(c,e,tp)
	return c:IsSetCard(0x51) and c:IsLevel(4) and not c:IsCode(29021114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判定函数，判断是否满足发动条件
function c29021114.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家卡组中是否存在满足条件的4星零件怪兽
		and Duel.IsExistingMatchingCard(c29021114.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c29021114.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c29021114.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
