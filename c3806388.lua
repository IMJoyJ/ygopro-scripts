--混沌核
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以除外的1只自己的「混沌壳」为对象才能发动。那只怪兽特殊召唤。
-- ③：表侧表示的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册3个效果：特殊召唤条件、效果①（从手卡特殊召唤）和效果②（特殊召唤成功时的处理）以及效果③（离场除外）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：从自己的手卡·墓地把1只暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以除外的1只自己的「混沌壳」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
end
-- 限制该卡只能通过效果特殊召唤，不能通常召唤。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 用于判断除外的卡是否为暗属性怪兽的过滤函数。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果①的费用支付函数，选择1只暗属性怪兽除外作为费用。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的暗属性怪兽可以除外作为费用。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的暗属性怪兽作为除外费用。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的发动条件判断函数，检查是否可以特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，将此卡特殊召唤并设置后续限制。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置效果①的后续限制，禁止在本回合将非光·暗属性的同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.spelimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果到玩家场上。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数，禁止召唤非光·暗属性的同调怪兽。
function s.spelimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- 用于判断除外的「混沌壳」是否可以特殊召唤的过滤函数。
function s.spfilter(c,e,tp)
	return c:IsCode(77312273) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件判断函数，检查是否有符合条件的「混沌壳」可以特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有符合条件的「混沌壳」可以特殊召唤。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的「混沌壳」作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果②的处理信息，表示将特殊召唤选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的发动处理函数，将选中的「混沌壳」特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
