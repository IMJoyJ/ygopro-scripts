--教導の天啓アディン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把「教导的天启 阿东」以外的1只「教导」怪兽特殊召唤。
function c33296432.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33296432,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33296432)
	e1:SetCondition(c33296432.spcon)
	e1:SetTarget(c33296432.sptg)
	e1:SetOperation(c33296432.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c33296432.indes)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把「教导的天启 阿东」以外的1只「教导」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33296432,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,33296433)
	e3:SetCondition(c33296432.spcon2)
	e3:SetTarget(c33296432.sptg2)
	e3:SetOperation(c33296432.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查场上是否存在从额外卡组特殊召唤的怪兽
function c33296432.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动条件函数，判断场上是否存在从额外卡组特殊召唤的怪兽
function c33296432.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张从额外卡组特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c33296432.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤的条件
function c33296432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理函数，将卡片特殊召唤到场上
function c33296432.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果值函数，判断目标怪兽是否从额外卡组特殊召唤
function c33296432.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动条件函数，判断该卡是否因战斗或效果被破坏且在场上
function c33296432.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，筛选卡组中满足条件的「教导」怪兽
function c33296432.spfilter(c,e,tp)
	return c:IsSetCard(0x145) and not c:IsCode(33296432) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤的条件
function c33296432.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的「教导」怪兽
		and Duel.IsExistingMatchingCard(c33296432.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，从卡组选择并特殊召唤符合条件的怪兽
function c33296432.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c33296432.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行将选中的怪兽卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
