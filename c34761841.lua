--クリムゾン・リゾネーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。
-- ①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只的场合才能发动。从手卡·卡组把「深红共鸣者」以外的最多2只「共鸣者」怪兽特殊召唤。
function c34761841.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。②：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只的场合才能发动。从手卡·卡组把「深红共鸣者」以外的最多2只「共鸣者」怪兽特殊召唤。
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
	-- 注册自定义活动计数器，用于检测玩家在额外卡组特殊召唤怪兽的情况
	Duel.AddCustomActivityCounter(34761841,ACTIVITY_SPSUMMON,c34761841.counterfilter)
end
-- 活动计数器的过滤函数：允许从额外卡组以外的特殊召唤，或者是表侧表示的暗属性龙族同调怪兽的特殊召唤
function c34761841.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
		or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup())
end
-- 效果①的发动条件：自己场上没有怪兽存在
function c34761841.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果发动的Cost：检查本回合是否进行过不符合条件的额外卡组特殊召唤，并注册本回合不能从额外卡组特殊召唤非暗属性龙族同调怪兽的誓约效果
function c34761841.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查本回合是否进行过不符合条件的额外卡组特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(34761841,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。②：自己场上的其他怪兽只有龙族·暗属性同调怪兽1只的场合才能发动。从手卡·卡组把「深红共鸣者」以外的最多2只「共鸣者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34761841.splimit)
	-- 注册限制从额外卡组特殊召唤非龙族·暗属性同调怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤怪兽的过滤函数：禁止从额外卡组特殊召唤非暗属性龙族同调怪兽
function c34761841.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 效果①的Target：检查怪兽区是否有空位以及这张卡是否可以特殊召唤
function c34761841.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自己场上的主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的Operation：若这张卡在手卡中存在，则表侧表示特殊召唤到场上
function c34761841.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：用于判断场上的怪兽是否为表侧表示的暗属性龙族同调怪兽
function c34761841.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的发动条件：自己场上除自身以外的其他怪兽仅有1只且必须是暗属性龙族同调怪兽
function c34761841.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的暗属性龙族同调怪兽
	return Duel.IsExistingMatchingCard(c34761841.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查自己场上除自身以外的其他怪兽的总数量是否刚好为1只
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())==1
end
-- 过滤函数：筛选手卡或卡组中除「深红共鸣者」以外的符合特殊召唤条件的「共鸣者」怪兽
function c34761841.spfilter(c,e,tp)
	return c:IsSetCard(0x57) and not c:IsCode(34761841) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target：检查怪兽区是否有空位，以及手卡或卡组是否存在符合条件的「共鸣者」怪兽
function c34761841.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在至少1只除「深红共鸣者」以外的符合条件的「共鸣者」怪兽
		and Duel.IsExistingMatchingCard(c34761841.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡或卡组将怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的Operation：计算可特殊召唤的数量，并从手卡或卡组选择最多2只除「深红共鸣者」以外的「共鸣者」怪兽特殊召唤
function c34761841.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local ct=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1到ct张符合特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c34761841.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
