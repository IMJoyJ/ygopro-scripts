--森の番人グリーン・バブーン
-- 效果：
-- ①：这张卡在手卡·墓地存在，自己场上的表侧表示的兽族怪兽被效果破坏送去墓地时，支付1000基本分才能发动。这张卡特殊召唤。
function c46668237.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上的表侧表示的兽族怪兽被效果破坏送去墓地时，支付1000基本分才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46668237,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46668237.condition)
	e1:SetCost(c46668237.cost)
	e1:SetTarget(c46668237.target)
	e1:SetOperation(c46668237.operation)
	c:RegisterEffect(e1)
end
-- 筛选送去墓地的怪兽群中符合条件的怪兽：必须为怪兽、兽族、之前由我方控制、之前表侧表示、之前在主要怪兽区，且之前在场上种族为兽族（即作为我方场上表侧表示的兽族怪兽被破坏）。
function c46668237.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.band(c:GetPreviousRaceOnField(),RACE_BEAST)~=0
end
-- 发动条件判断：本次送去墓地的怪兽群中不能包含此卡自身，且至少存在1只满足cfilter条件的兽族怪兽，并且此次送去墓地的原因是“效果破坏”（REASON_DESTROY + REASON_EFFECT）。
function c46668237.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c46668237.cfilter,1,nil,tp) and bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT
end
-- 代价函数：作为效果发动的代价，需要支付1000基本分；在检查阶段确认能否支付，在实际发动时支付。
function c46668237.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：判断玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 目标/发动检查：满足发动时机后，还需我方主要怪兽区有空位，且这张卡本身满足特殊召唤条件（无召唤限制）才能发动。
function c46668237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果处理将要把“这张卡”特殊召唤，用于系统结算和连锁时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若此卡仍与效果关联（未被无效或离场重置），则将其特殊召唤。
function c46668237.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
