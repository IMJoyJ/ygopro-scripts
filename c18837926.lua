--切れぎみ隊長
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c18837926.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
-- 判断卡片是否为等级4以下的怪兽，且能够被当前效果特殊召唤（检查召唤条件/苏生限制）。
function c18837926.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数的合法性判定：若为连锁处理中确认对象（chkc非空），则对象必须是自己墓地中满足条件的4星以下怪兽；若为发动时点判定（chk==0），则检查是否存在满足条件的对象以及特殊召唤区域是否可用。
function c18837926.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18837926.filter(chkc,e,tp) end
	-- 发动时点判定：检查自己墓地是否存在至少1只满足条件的4星以下怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c18837926.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动时点判定：检查自己主要怪兽区域是否存在空位，以确保可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 弹出选择提示，要求玩家选择要特殊召唤的怪兽（提示文字为“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的4星以下怪兽作为对象，并将其登记为本次连锁的对象卡。
	local g=Duel.SelectTarget(tp,c18837926.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记操作信息：本效果将进行1只怪兽的特殊召唤，供其他卡片的发动条件检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：确认对象仍与效果关联后，将对象怪兽以表侧守备表示特殊召唤，并使其效果无效化，最后完成特殊召唤。
function c18837926.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的目标怪兽（即从墓地选出的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与效果关联且可以特殊召唤成功；若是，则以表侧守备表示进行特殊召唤（先经由SpecialSummonStep进入待处理步骤）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
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
	-- 完成全部特殊召唤步骤，正式让之前通过SpecialSummonStep特殊召唤的怪兽成功出场。
	Duel.SpecialSummonComplete()
end
