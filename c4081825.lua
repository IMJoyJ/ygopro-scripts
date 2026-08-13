--カオス・インフィニティ
-- 效果：
-- ①：场上的守备表示怪兽全部变成表侧攻击表示。那之后，从自己的卡组·墓地选1只「机皇」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c4081825.initial_effect(c)
	-- ①：场上的守备表示怪兽全部变成表侧攻击表示。那之后，从自己的卡组·墓地选1只「机皇」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c4081825.target)
	e1:SetOperation(c4081825.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断候选卡是否为「机皇」怪兽，且可以被当前效果特殊召唤（不检查召唤条件/苏生限制）。
function c4081825.spfilter(c,e,tp)
	return c:IsSetCard(0x13) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法性检查：需要场上存在守备表示怪兽、我方主要怪兽区有空位、且卡组·墓地存在至少1只可特殊召唤的「机皇」怪兽。
function c4081825.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方怪兽区）是否存在至少1只守备表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查我方主要怪兽区是否存在可用空格（用于后续特殊召唤）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方卡组·墓地是否存在至少1只满足spfilter（「机皇」且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c4081825.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，预期从卡组·墓地特殊召唤1只怪兽，供相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：先将场上所有守备表示怪兽变为表侧攻击表示；若我方仍有空位，则从卡组·墓地选择1只「机皇」怪兽特殊召唤，并使其效果无效化、结束阶段破坏。
function c4081825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有守备表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将守备表示怪兽全部变为表侧攻击表示。
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	-- 确认我方主要怪兽区是否有空位，若没有则无法进行特殊召唤并终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽卡（特殊召唤相关选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地选择1只满足spfilter且不受王家长眠之谷影响的「机皇」怪兽作为特殊召唤对象。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4081825.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
		-- 中断当前效果处理链，使后续特殊召唤独立结算，避免与之前变更表示形式共享时点。
		Duel.BreakEffect()
		-- 将选中的「机皇」怪兽以表侧表示特殊召唤到我方场上（特殊召唤流程步骤之一）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 完成特殊召唤流程，正式将怪兽特殊召唤到场。
		Duel.SpecialSummonComplete()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(4081825,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c4081825.descon)
		e3:SetOperation(c4081825.desop)
		e3:SetCountLimit(1)
		-- 将该结束阶段破坏效果注册到场上，持续在结束阶段进行判定。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判定是否执行破坏：仅当特殊召唤的怪兽仍带有对应标记且未被重置时，才允许在结束阶段破坏；否则取消该效果。
function c4081825.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(4081825)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏效果处理：对被特殊召唤的怪兽执行破坏。
function c4081825.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行破坏操作，破坏原因为效果破坏（由卡片效果导致的破坏）。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
