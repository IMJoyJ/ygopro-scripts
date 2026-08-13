--シンクロン・エクスプローラー
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36643046.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「同调士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36643046,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c36643046.sumtg)
	e1:SetOperation(c36643046.sumop)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：目标必须是卡名带有「同调士」的怪兽，且能够被当前效果特殊召唤（满足召唤条件和苏生限制）。
function c36643046.filter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的对象合法性检查：若传入候选对象，则确认其在我方墓地且满足筛选条件；同时确认发动时墓地和怪兽区条件均满足。
function c36643046.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36643046.filter(chkc,e,tp) end
	-- 发动时检查：自己墓地是否存在至少1只满足筛选条件并能成为本效果对象的「同调士」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36643046.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且我方主要怪兽区有空位，以确保特殊召唤能够进行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向操作玩家显示选择提示，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从我方墓地选择1只满足条件的「同调士」怪兽，并将其登记为本效果的对象。
	local g=Duel.SelectTarget(tp,c36643046.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将把1只对象怪兽特殊召唤，供后续连锁判定与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽并确认其仍与本效果关联后，将其以表侧表示特殊召唤到我方场上；若特殊召唤成功，则对其附加效果无效化处理。
function c36643046.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择并登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到我方怪兽区；若特殊召唤没有成功，则直接终止后续无效化处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
