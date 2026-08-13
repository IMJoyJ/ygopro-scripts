--魔轟神クルス
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合，以自己墓地1只其他的4星以下的「魔轰神」怪兽为对象发动。那只怪兽特殊召唤。
function c19439119.initial_effect(c)
	-- ①：这张卡从手卡丢弃去墓地的场合，以自己墓地1只其他的4星以下的「魔轰神」怪兽为对象发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19439119,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c19439119.spcon)
	e1:SetTarget(c19439119.sptg)
	e1:SetOperation(c19439119.spop)
	c:RegisterEffect(e1)
end
-- 判断触发条件：该卡从手牌被丢弃送去墓地（之前位置为手牌且丢弃原因包含REASON_DISCARD）。
function c19439119.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 定义可选怪兽的筛选条件：自己墓地1只其他的4星以下的「魔轰神」怪兽且能被特殊召唤。
function c19439119.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动时处理：选择自己墓地1只符合条件的「魔轰神」怪兽（不能选自身）作为效果对象，并设置特殊召唤的操作信息。
function c19439119.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19439119.filter(chkc,e,tp) and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「魔轰神」怪兽（不能选择自身）作为效果对象。
	local g=Duel.SelectTarget(tp,c19439119.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 将本次操作信息设置为特殊召唤，目标为已选对象，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的结算：取回对象卡，若与效果关联，则将其以表侧攻击表示特殊召唤。
function c19439119.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到持有者（自己）场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
