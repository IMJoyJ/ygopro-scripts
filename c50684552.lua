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
-- 效果发动条件：该卡因破坏而进入墓地且之前在场上正面表示过
function c50684552.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 检索满足条件的卡片组：等级4以下、名字带有「机人」、机械族、可以特殊召唤
function c50684552.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x16) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点的确认：手牌中存在满足条件的怪兽且场上存在空位
function c50684552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c50684552.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若场上存在空位则提示选择并特殊召唤符合条件的怪兽
function c50684552.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,c50684552.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
