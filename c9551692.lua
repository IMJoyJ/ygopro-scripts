--マスター・オブ・HAM
-- 效果：
-- 兽族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤·反转的场合才能发动。从自己的手卡·卡组把1只反转怪兽里侧守备表示特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己的场上（表侧表示）·墓地把2只反转怪兽除外才能发动。这张卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（融合召唤/反转时里侧特召手卡/卡组的反转怪兽）以及②效果（在墓地时除外场上/墓地2只反转怪兽里侧自力特召）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：兽族怪兽×2
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,true)
	-- ①：这张卡融合召唤·反转的场合才能发动。从自己的手卡·卡组把1只反转怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，从自己的场上（表侧表示）·墓地把2只反转怪兽除外才能发动。这张卡里侧守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id+o)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(s.sscost)
	e3:SetTarget(s.sstg)
	e3:SetOperation(s.ssop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否是通过融合召唤特殊召唤的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤满足“是反转怪兽且可以里侧守备表示特殊召唤”条件的卡
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动准备，检查怪兽区域是否有空位，以及手卡或卡组中是否存在可特殊召唤的反转怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或卡组中是否存在至少1只满足条件的反转怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：特殊召唤手卡或卡组中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理：从手卡或卡组选择1只反转怪兽里侧守备表示特殊召唤，并给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1只满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤满足“是反转怪兽、在场上表侧表示或在墓地、且可以作为Cost除外”条件的卡
function s.ssfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价，从自己的场上（表侧表示）或墓地将2只反转怪兽除外
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上（表侧表示）和墓地是否存在至少2只可除外的反转怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上（表侧表示）或墓地选择2只满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动准备，检查怪兽区域是否有空位，以及墓地的这张卡是否可以里侧守备表示特殊召唤
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置连锁的操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡里侧守备表示特殊召唤，并添加“离场时除外”的约束
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，并尝试将其以里侧守备表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
