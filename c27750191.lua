--横綱犬
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c27750191.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27750191,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27750191.sumtg)
	e1:SetOperation(c27750191.sumop)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是调整怪兽，且能被当前效果特殊召唤（需满足召唤条件和苏生限制）。
function c27750191.filter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标阶段处理：确认自己场上有特殊召唤的空位，且手卡·墓地存在至少1只符合条件的调整怪兽。
function c27750191.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定时先检查自己场上是否有可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查手卡·墓地是否存在至少1只满足filter条件的调整怪兽。
		and Duel.IsExistingMatchingCard(c27750191.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从手卡·墓地特殊召唤1只怪兽，供连锁判定与时点记录使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时的操作：若有空位则选择手卡·墓地的1只调整怪兽特殊召唤，成功后给该怪兽附加效果无效化状态，最后完成特殊召唤。
function c27750191.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的主怪兽区；若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只符合条件的调整怪兽（墓地部分受王家长眠之谷影响的卡不会被选中）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27750191.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 以表侧表示对选择的怪兽执行特殊召唤步骤，若成功则继续附加无效化效果。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成这次特殊召唤处理，将之前SpecialSummonStep累积的怪兽正式特殊召唤出场。
	Duel.SpecialSummonComplete()
end
