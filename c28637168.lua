--クレーンクレーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只3星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c28637168.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤成功时，以自己墓地1只3星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28637168,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28637168)
	e1:SetTarget(c28637168.sptg)
	e1:SetOperation(c28637168.spop)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的墓地怪兽：等级为3星，且能够被当前效果特殊召唤（满足特殊召唤条件与苏生限制）。
function c28637168.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择流程：先确认连锁对象是否为墓地中满足条件的3星怪兽；发动条件为我方主要怪兽区域有空位，且墓地存在至少1只可特殊召唤的3星怪兽。
function c28637168.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28637168.spfilter(chkc,e,tp) end
	-- 检查我方主要怪兽区域是否有可用空位，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方墓地是否存在至少1只满足筛选条件（3星且可特殊召唤）的怪兽，并能成为此效果的对象。
		and Duel.IsExistingTarget(c28637168.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示选择提示，要求其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方墓地选择1只满足条件的3星怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28637168.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，声明本效果将进行1只怪兽的特殊召唤处理，供连锁判定和时点触发使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：确认对象怪兽仍与效果关联后，将其以表侧表示特殊召唤，同时给该怪兽施加效果无效化状态（无效其怪兽效果），最后完成特殊召唤。
function c28637168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的第一张对象卡（即作为对象的墓地3星怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与效果关联（未被重置或离场），若是则以表侧表示进行特殊召唤（分步处理，待之后完成）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤分步处理，正式结算本次特殊召唤。
	Duel.SpecialSummonComplete()
end
