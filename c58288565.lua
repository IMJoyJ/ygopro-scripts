--バタフライ・フィッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。
-- ②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：初始化①效果（回收手卡）、②效果（墓地特召）以及用于限制非水属性额外特召的自定义计数器。
function s.initial_effect(c)
	-- ①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于检测本回合是否特殊召唤过非水属性的额外卡组怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：非额外卡组特殊召唤的怪兽，或者是水属性怪兽（即不计入非水属性额外特召的限制）。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的发动条件：这张卡作为怪兽效果发动的代价（COST）被送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的代价：检查本回合是否未从额外卡组特殊召唤过非水属性怪兽，并注册“本回合自己不是水属性怪兽不能从额外卡组特殊召唤”的誓约限制。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在此效果发动前，是否没有从额外卡组特殊召唤过非水属性怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤非水属性怪兽的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：不能特殊召唤非水属性且从额外卡组出场的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- ①效果的靶向处理：检查自身是否可以加入手卡，并设置回收手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前连锁的操作信息为：将自身（1张卡）加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：如果自身仍存在于墓地且不受王家长眠之谷影响，则将自身加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关联，且不受王家长眠之谷的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身因效果加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤函数：被战斗以外送去自己墓地的怪兽。
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_BATTLE) and c:IsControler(tp)
end
-- ②效果的发动条件：有怪兽被战斗以外送去自己墓地，且送去墓地的卡中不包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的代价：检查手卡中是否有可以丢弃的卡，且本回合未从额外卡组特召过非水属性怪兽。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以作为代价丢弃去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND,0,1,nil)
		-- 并且本回合在此效果发动前，没有从额外卡组特殊召唤过非水属性怪兽。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),1,1,REASON_COST+REASON_DISCARD)
	-- 这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤非水属性怪兽的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的靶向处理：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身（1张卡）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的效果处理：如果自身仍存在于墓地且不受王家长眠之谷影响，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关联，且不受王家长眠之谷的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
