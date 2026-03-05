--切れぎみ隊長
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c18837926.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18837926,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c18837926.sptg)
	e1:SetOperation(c18837926.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤器，用于判断墓地中的怪兽是否满足4星以下且可以特殊召唤的条件。
function c18837926.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的目标为己方墓地中的4星以下且可特殊召唤的怪兽。
function c18837926.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18837926.filter(chkc,e,tp) end
	-- 规则层面作用：检查是否存在满足条件的墓地怪兽。
	if chk==0 then return Duel.IsExistingTarget(c18837926.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 规则层面作用：检查己方场上是否有足够的怪兽区域进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 规则层面作用：向玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的墓地怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c18837926.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁的操作信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：定义效果处理函数，执行特殊召唤及后续效果无效化操作。
function c18837926.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上，并尝试将其特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 规则层面作用：完成所有特殊召唤步骤，结束本次特殊召唤流程。
	Duel.SpecialSummonComplete()
end
