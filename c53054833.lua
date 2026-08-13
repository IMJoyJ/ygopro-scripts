--SRダブルヨーヨー
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只3星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53054833.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只3星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53054833,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53054833.target)
	e1:SetOperation(c53054833.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足以下条件的墓地怪兽：等级3以下、属于「疾行机人」系列、且可被玩家tp用此效果特殊召唤（正常检查召唤条件与苏生限制）。
function c53054833.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x2016) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件和取对象判定：若已选对象则确认该对象在自己墓地、自己控制且满足筛选条件；若为发动时判定则检查是否有空余怪兽区以及墓地是否存在满足条件的可对象怪兽。
function c53054833.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53054833.filter(chkc,e,tp) end
	-- 效果发动时的条件之一：我方主要怪兽区必须存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时的条件之二：自己墓地存在至少1只满足筛选条件且能够成为此效果对象的「疾行机人」3星以下怪兽。
		and Duel.IsExistingTarget(c53054833.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给操作玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的满足条件的怪兽中选择1张，并将其设为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c53054833.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将进行特殊召唤，对象为已选择的怪兽，数量为1，供时点检测及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作：获取效果对象，若对象仍与效果存在关联，则将其特殊召唤上场。
function c53054833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获得效果发动时所选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到己方场上，不附加特殊召唤方式，不忽略召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
