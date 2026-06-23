--E・HERO ソリッドマン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「英雄」怪兽特殊召唤。
-- ②：这张卡被魔法卡的效果从怪兽区域送去墓地的场合，以「元素英雄 固态侠」以外的自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c45195443.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45195443,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45195443.sptg1)
	e1:SetOperation(c45195443.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被魔法卡的效果从怪兽区域送去墓地的场合，以「元素英雄 固态侠」以外的自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45195443,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,45195443)
	e2:SetCondition(c45195443.spcon2)
	e2:SetTarget(c45195443.sptg2)
	e2:SetOperation(c45195443.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的怪兽（4星以下、英雄卡组、可特殊召唤）
function c45195443.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判断函数，检查是否满足发动条件（场上存在空位且手卡存在符合条件的怪兽）
function c45195443.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c45195443.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，检查场上是否有空位，提示玩家选择要特殊召唤的怪兽并执行特殊召唤
function c45195443.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c45195443.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足效果发动条件（由魔法卡的效果送入墓地且来自怪兽区域）
function c45195443.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsType(TYPE_SPELL) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤函数，用于判断墓地中是否存在满足条件的怪兽（英雄卡组、非固态侠、可守备表示特殊召唤）
function c45195443.spfilter2(c,e,tp)
	return c:IsSetCard(0x8) and not c:IsCode(45195443) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理时的判断函数，检查是否满足发动条件（场上存在空位且墓地存在符合条件的怪兽）
function c45195443.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45195443.spfilter2(chkc,e,tp) end
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c45195443.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c45195443.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，检查目标怪兽是否仍然有效，若有效则将其守备表示特殊召唤
function c45195443.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
