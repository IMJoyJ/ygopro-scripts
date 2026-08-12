--バタフライ・フィッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。
-- ②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果并添加自定义活动计数器
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
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
	-- 添加用于特殊召唤限制的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 自定义计数器过滤条件：非额外卡组特召，或是表侧表示的水属性怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 效果1的发动条件：此卡作为怪兽效果发动的代价而被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 效果1的发动代价：在chk为0时检查本回合限制，并注册本回合不能特殊召唤水属性以外额外怪兽的限制效果
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查玩家本回合是否没有从额外卡组特殊召唤过水属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。①：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡加入手卡。②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能从额外卡组特殊召唤水属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤条件：非水属性且从额外卡组特殊召唤的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果1的发动目标：在chk为0时检查此卡是否能加入手卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将此卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果1的执行操作：将此卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与效果关联且不受王家之谷的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡送回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤函数：判断卡片是否为被战斗以外原因送去自己墓地的怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_BATTLE) and c:IsControler(tp)
end
-- 效果2的发动条件：判断是否有怪兽被战斗以外送去自己墓地且不包含此卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果2的发动代价：在chk为0时检查是否能丢弃1张手卡且本回合未特殊召唤过非水属性的额外卡组怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查玩家手卡中是否存在可以作为代价丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND,0,1,nil)
		-- 以及检查本回合玩家是否未从额外卡组特殊召唤过水属性以外的怪兽
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 玩家将1张手卡丢弃去墓地
	Duel.DiscardHand(tp,aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),1,1,REASON_COST+REASON_DISCARD)
	-- 这些效果发动的回合，自己不是水属性怪兽不能从额外卡组特殊召唤。②：这张卡在墓地存在的状态，怪兽被战斗以外送去自己墓地的场合，把1张手卡丢弃去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能从额外卡组特殊召唤水属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果2的发动目标：在chk为0时检查怪兽区域空格以及特殊召唤可能性，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk为0时，检查玩家怪兽区域是否有空位以及此卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果2的执行操作：将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与效果关联且不受王家之谷的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
