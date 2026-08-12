--極星霊リョースアールヴ
-- 效果：
-- 这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级以下的1只名字带有「极星」的怪兽从手卡特殊召唤。
function c40666140.initial_effect(c)
	-- 这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级以下的1只名字带有「极星」的怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40666140,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40666140.sptg)
	e1:SetOperation(c40666140.spop)
	c:RegisterEffect(e1)
end
-- 选择自己场上表侧表示存在的怪兽，该怪兽等级大于0且手卡存在名字带有「极星」且等级不超过该怪兽等级的怪兽。
function c40666140.filter(c,e,tp)
	local lv=c:GetLevel()
	-- 满足条件的怪兽等级大于0且手卡存在名字带有「极星」且等级不超过该怪兽等级的怪兽。
	return c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(c40666140.filter2,tp,LOCATION_HAND,0,1,nil,lv,e,tp)
end
-- 名字带有「极星」的怪兽，等级不超过指定等级且可以特殊召唤。
function c40666140.filter2(c,lv,e,tp)
	return c:IsSetCard(0x42) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择自己场上表侧表示存在的1只怪兽作为效果对象，检查是否满足条件。
function c40666140.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40666140.filter(chkc,e,tp) end
	-- 检查自己场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c40666140.filter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40666140.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理时将要特殊召唤的卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果的发动，检查是否有足够空位并确认目标怪兽是否有效。
function c40666140.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只名字带有「极星」且等级不超过目标怪兽等级的怪兽。
	local sg=Duel.SelectMatchingCard(tp,c40666140.filter2,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),e,tp)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽从手卡特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
