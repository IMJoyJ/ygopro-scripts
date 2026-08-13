--ワンダーガレージ
-- 效果：
-- 盖放的这张卡被破坏送去墓地时，可以从手卡把1只4星以下的名字带有「机人」的机械族怪兽特殊召唤。
function c50684552.initial_effect(c)
	-- 盖放的这张卡被破坏送去墓地时，可以从手卡把1只4星以下的名字带有「机人」的机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50684552,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c50684552.spcon)
	e1:SetTarget(c50684552.sptg)
	e1:SetOperation(c50684552.spop)
	c:RegisterEffect(e1)
end
-- 判断诱发条件：这张卡因破坏被送去墓地，且被破坏前在场上为里侧表示。
function c50684552.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 筛选可特殊召唤的怪兽：手卡中等级4以下、名字带有「机人」、机械族，且满足特殊召唤条件。
function c50684552.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x16) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时进行合法性检查并设置操作信息：确认有怪兽区空位且手卡存在符合条件的怪兽，然后预定从手卡特殊召唤1只怪兽。
function c50684552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足spfilter条件的怪兽（4星以下、机人、机械族、可特殊召唤）。
		and Duel.IsExistingMatchingCard(c50684552.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的操作信息：预定进行1只从手卡发起的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若主要怪兽区仍有空位，则从手卡选择1只符合条件的怪兽，表侧表示特殊召唤到自己场上。
function c50684552.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c50684552.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
