--クリムゾン・リゾネーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。
-- ①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只的场合才能发动。从手卡·卡组把「深红共鸣者」以外的最多2只「共鸣者」怪兽特殊召唤。
function c34761841.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34761841,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34761841)
	e1:SetCondition(c34761841.spcon1)
	e1:SetCost(c34761841.spcost)
	e1:SetTarget(c34761841.sptg1)
	e1:SetOperation(c34761841.spop1)
	c:RegisterEffect(e1)
	-- ②：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只的场合才能发动。从手卡·卡组把「深红共鸣者」以外的最多2只「共鸣者」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34761841,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34761842)
	e2:SetCondition(c34761841.spcon2)
	e2:SetCost(c34761841.spcost)
	e2:SetTarget(c34761841.sptg2)
	e2:SetOperation(c34761841.spop2)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在本回合中特殊召唤的非额外卡组怪兽数量。
	Duel.AddCustomActivityCounter(34761841,ACTIVITY_SPSUMMON,c34761841.counterfilter)
end
-- 计数器的过滤函数，若怪兽不是从额外卡组召唤，或为龙族·暗属性同调怪兽，则不计入计数。
function c34761841.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
		or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 效果①的发动条件：自己场上没有怪兽存在。
function c34761841.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果①②的发动费用：本回合中未发动过此效果。
function c34761841.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已发动过此效果。
	if chk==0 then return Duel.GetCustomActivityCount(34761841,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止特殊召唤的永续效果，仅对额外卡组中非龙族·暗属性同调怪兽生效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34761841.splimit)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤的过滤函数，仅禁止额外卡组中非龙族·暗属性同调怪兽的特殊召唤。
function c34761841.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 效果①的发动时的处理：检查是否满足特殊召唤条件。
function c34761841.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的发动效果处理：将自身特殊召唤。
function c34761841.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断场上是否存在龙族·暗属性同调怪兽的过滤函数。
function c34761841.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的发动条件：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只。
function c34761841.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在龙族·暗属性同调怪兽。
	return Duel.IsExistingMatchingCard(c34761841.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查自己场上除自身外是否只有1只怪兽。
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())==1
end
-- 用于筛选可特殊召唤的「共鸣者」怪兽的过滤函数。
function c34761841.spfilter(c,e,tp)
	return c:IsSetCard(0x57) and not c:IsCode(34761841) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时的处理：检查是否满足特殊召唤条件。
function c34761841.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c34761841.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将特殊召唤最多2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的发动效果处理：从手卡或卡组中特殊召唤最多2只「共鸣者」怪兽。
function c34761841.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的召唤位置数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local ct=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c34761841.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
