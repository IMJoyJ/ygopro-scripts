--ウォークライ・ガトス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有战士族·地属性怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
function c19771459.initial_effect(c)
	-- 效果原文：①：自己场上有战士族·地属性怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19771459,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19771459.spcon1)
	e1:SetTarget(c19771459.sptg1)
	e1:SetOperation(c19771459.spop1)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19771459,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,19771459)
	e2:SetCondition(c19771459.spcon2)
	e2:SetTarget(c19771459.sptg2)
	e2:SetOperation(c19771459.spop2)
	c:RegisterEffect(e2)
end
-- 规则层面：定义一个过滤函数，用于判断场上是否存在己方的正面表示的战士族地属性怪兽。
function c19771459.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsControler(tp)
end
-- 规则层面：判断是否有己方的战士族地属性怪兽被成功召唤。
function c19771459.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19771459.cfilter,1,nil,tp)
end
-- 规则层面：设置效果的发动条件检查函数，判断是否满足特殊召唤的条件。
function c19771459.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置连锁处理信息，表明将要特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：定义效果发动后的处理函数，执行将卡特殊召唤的操作。
function c19771459.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：执行将卡特殊召唤到己方场上的操作。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面：判断该卡是否因对方效果从怪兽区域被送去墓地。
function c19771459.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 规则层面：定义一个过滤函数，用于筛选5星以上且为「战吼」族的怪兽。
function c19771459.spfilter2(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：设置效果的发动条件检查函数，判断是否满足特殊召唤的条件。
function c19771459.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查手牌或卡组中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c19771459.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面：设置连锁处理信息，表明将要从手牌或卡组特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 规则层面：定义效果发动后的处理函数，执行选择并特殊召唤怪兽的操作。
function c19771459.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查场上是否有足够的怪兽区域用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：向玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：从手牌或卡组中选择一张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19771459.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 规则层面：执行将选中的怪兽特殊召唤到己方场上的操作。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
