--ドラゴンメイド・ナサリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以除「半龙女仆·育婴龙女」外的自己墓地1只4星以下的「半龙女仆」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
function c40398073.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以除「半龙女仆·育婴龙女」外的自己墓地1只4星以下的「半龙女仆」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40398073,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,40398073)
	e1:SetTarget(c40398073.sptg1)
	e1:SetOperation(c40398073.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40398073,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40398074)
	e3:SetTarget(c40398073.sptg2)
	e3:SetOperation(c40398073.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的墓地4星以下的半龙女仆怪兽（不包括自身）并可特殊召唤
function c40398073.spfilter1(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelBelow(4) and not c:IsCode(40398073) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断函数，用于判断是否满足特殊召唤的条件
function c40398073.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40398073.spfilter1(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c40398073.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c40398073.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将目标怪兽特殊召唤
function c40398073.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选满足条件的7星半龙女仆怪兽并可特殊召唤
function c40398073.spfilter2(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断函数，用于判断是否满足发动条件
function c40398073.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 判断玩家场上是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 判断玩家手牌或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c40398073.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，确定将此卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，将此卡送回手牌并特殊召唤1只7星半龙女仆怪兽
function c40398073.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在场上且成功送回手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 判断此卡是否在手牌且场上是否有足够的怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的手牌或墓地的7星半龙女仆怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c40398073.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
