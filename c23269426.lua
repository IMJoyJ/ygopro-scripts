--最期の同調
-- 效果：
-- ①：以自己场上1只3星怪兽为对象才能发动。那1只同名怪兽从自己的手卡·墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。作为对象的怪兽在这个回合的结束阶段破坏。
function c23269426.initial_effect(c)
	-- ①：以自己场上1只3星怪兽为对象才能发动。那1只同名怪兽从自己的手卡·墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。作为对象的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23269426.target)
	e1:SetOperation(c23269426.activate)
	c:RegisterEffect(e1)
end
-- 作为特殊召唤的过滤条件：检查候选怪兽与对象怪兽卡名相同，并且满足可以被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c23269426.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 作为取对象目标的过滤条件：选择自己场上表侧表示且等级为3的怪兽，且手卡或墓地存在至少1只与之同名的可特殊召唤怪兽。
function c23269426.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevel(3)
		-- 进一步确认手卡·墓地中存在至少1只与候选对象同名的可特殊召唤怪兽，以保证发动时有可特召的卡。
		and Duel.IsExistingMatchingCard(c23269426.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 效果发动时的目标选择函数：首先处理连锁选择时的合法性检查，然后进行发动条件判定；满足条件后由玩家选择对象。
function c23269426.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c23269426.filter(chkc,e,tp) end
	-- 发动条件判定：检查自己场上是否有空余的怪兽区可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：检查自己场上是否存在符合条件的3星表侧怪兽作为效果对象。
		and Duel.IsExistingTarget(c23269426.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要作为对象的表侧表示的怪兽（选择框消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的3星表侧怪兽，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,c23269426.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁的处理将进行1次特殊召唤，位置为手卡·墓地，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：处理特殊召唤、无效化以及结束阶段破坏。先确认空位和对象状态，再从手卡·墓地选择同名怪兽特殊召唤，对其附加效果无效化，并给对象怪兽附加结束阶段破坏效果。
function c23269426.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认怪兽区有空位，若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽（选择框消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只与对象怪兽同名的可特殊召唤怪兽（经由王家长眠之谷过滤，墓地中不受其影响的卡才能选择）。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c23269426.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
	-- 若成功选择怪兽且特殊召唤的第一步成功，则对这只怪兽附加无效化效果。
	if sg:GetCount()>0 and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化（EFFECT_DISABLE：怪兽效果无效）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化（EFFECT_DISABLE_EFFECT：效果适用无效）。完成特殊召唤后，开始为对象怪兽设置结束阶段破坏效果。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e2,true)
	end
	-- 完成整套特殊召唤流程（与Duel.SpecialSummonStep配对，最终确定特殊召唤）。
	Duel.SpecialSummonComplete()
	-- 作为对象的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(c23269426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	tc:RegisterEffect(e1)
end
-- 结束阶段处理函数：将效果持有者（即作为对象的怪兽）破坏。
function c23269426.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏效果持有者（即作为对象的怪兽）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
