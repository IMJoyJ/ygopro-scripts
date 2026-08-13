--レッドアイズ・スピリッツ
-- 效果：
-- ①：以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
function c44397496.initial_effect(c)
	-- ①：以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c44397496.target)
	e1:SetOperation(c44397496.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断卡是否为「真红眼」怪兽，且可以被当前效果特殊召唤。
function c44397496.filter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象时的合法性判断：若检查已选对象，则要求对象是己方墓地的「真红眼」怪兽且可特殊召唤；若为发动时点检查，则要求己方主要怪兽区有空位且墓地存在符合条件的对象。
function c44397496.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44397496.filter(chkc,e,tp) end
	-- 发动条件判定：己方主要怪兽区存在可用空格，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：墓地存在1只以上符合条件的「真红眼」怪兽，且可作为当前取对象效果的对象。
		and Duel.IsExistingTarget(c44397496.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方墓地选择1只符合条件的「真红眼」怪兽，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44397496.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理确定要进行特殊召唤，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：获得连锁登记的对象，确认其仍与效果关联后，将其特殊召唤。
function c44397496.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个对象卡，即选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，按规则检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
