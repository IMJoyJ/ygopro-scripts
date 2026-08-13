--ロスト・スター・ディセント
-- 效果：
-- ①：以自己墓地1只同调怪兽为对象才能发动。那只怪兽的等级下降1星，守备力变成0守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能把表示形式变更。
function c42079445.initial_effect(c)
	-- ①：以自己墓地1只同调怪兽为对象才能发动。那只怪兽的等级下降1星，守备力变成0守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42079445.sptg)
	e1:SetOperation(c42079445.spop)
	c:RegisterEffect(e1)
end
-- 检查候选怪兽是否为同调怪兽，并确认其能否以表侧守备表示被当前效果特殊召唤（含苏生限制/召唤条件检查）。
function c42079445.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动阶段的目标指定与合法性判定：若为连锁处理中检查对象，则确认对象是自己墓地的同调怪兽且满足特殊召唤条件；若为发动判定，则还需自己主要怪兽区有空位且墓地存在至少1只符合条件的同调怪兽。
function c42079445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42079445.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上存在可用的主要怪兽区空格，用于特殊召唤那只同调怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足“同调怪兽且可被表侧守备表示特殊召唤”的卡可以选择为对象。
		and Duel.IsExistingTarget(c42079445.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示，用于后续从墓地选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的同调怪兽作为效果的对象，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c42079445.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁的操作信息：进行1次特殊召唤，对象为已选择的怪兽，用于其他卡（如星尘龙、王家长眠之谷）进行效果发动的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得发动卡与对象，若对象仍与效果相关，则将其以表侧守备表示特殊召唤，并依次附加效果无效化、效果无效（离场仍无效）、等级下降1星、守备力变0、不能变更表示形式，最后完成特殊召唤处理。
function c42079445.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动时选择的对象卡（墓地那只同调怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与本次效果相关联且能够被特殊召唤，然后将其以表侧守备表示作为特殊召唤步骤处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 对应“这个效果特殊召唤的怪兽的效果无效化”，给特殊召唤成功的怪兽附加EFFECT_DISABLE，使其场上发动的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 对应“这个效果特殊召唤的怪兽的效果无效化”，追加EFFECT_DISABLE_EFFECT，使其在离场后所发动的效果也被无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 对应“那只怪兽的等级下降1星”，令该怪兽等级减少1。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_LEVEL)
		e3:SetValue(-1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		-- 对应“守备力变成0”，将该怪兽的守备力最终值设为0。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4,true)
		-- 对应“不能把表示形式变更”，令该怪兽不能变更表示形式；随后完成整个特殊召唤流程（Duel.SpecialSummonComplete）。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5,true)
	end
	-- 结束分步特殊召唤，正式完成特殊召唤过程，使之前的SpecialSummonStep生效。
	Duel.SpecialSummonComplete()
end
