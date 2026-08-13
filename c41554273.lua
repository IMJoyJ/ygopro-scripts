--ダイナミスト・ラッシュ
-- 效果：
-- 「雾动机龙突进」在1回合只能发动1张。
-- ①：从卡组把1只「雾动机龙」怪兽特殊召唤。这个效果特殊召唤的怪兽不受其他卡的效果影响，结束阶段破坏。
function c41554273.initial_effect(c)
	-- 「雾动机龙突进」在1回合只能发动1张。①：从卡组把1只「雾动机龙」怪兽特殊召唤。这个效果特殊召唤的怪兽不受其他卡的效果影响，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41554273+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41554273.target)
	e1:SetOperation(c41554273.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中满足「雾动机龙」字段且当前能被特殊召唤的怪兽，作为特殊召唤候选。
function c41554273.spfilter(c,e,tp)
	return c:IsSetCard(0xd8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法条件判定：确认我方怪兽区有空位且卡组中有可以特殊召唤的「雾动机龙」怪兽。
function c41554273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在空位，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「雾动机龙」怪兽。
		and Duel.IsExistingMatchingCard(c41554273.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：宣告本效果属于特殊召唤类别，预期从卡组处理1只怪兽的特殊召唤（用于系统检测等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：选择卡组中1只「雾动机龙」怪兽特殊召唤，并为其附加“不受其他卡的效果影响”与“结束阶段破坏”的持续效果。
function c41554273.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区有空位，否则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发出选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合特殊召唤条件的「雾动机龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,c41554273.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中怪兽且以表侧表示特殊召唤成功（特殊召唤步骤成功），则继续为其附加后续效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(tc)
		e1:SetCondition(c41554273.descon)
		e1:SetOperation(c41554273.desop)
		-- 将“结束阶段破坏该怪兽”的效果作为场上持续效果注册，使其在结束阶段触发。
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(41554273,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽不受其他卡的效果影响。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c41554273.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，将分步特殊召唤的怪兽正式出场。
	Duel.SpecialSummonComplete()
end
-- 破坏条件判定：被特殊召唤的怪兽仍带有本次召唤的标记时才执行破坏；否则重置该破坏效果并停止。
function c41554273.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(41554273)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 到时点后，将被特殊召唤的怪兽破坏。
function c41554273.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果破坏该怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 免疫判定：若试图作用于该怪兽的效果持有者不是本卡（雾动机龙突进）的持有者，则返回true，即该怪兽不受其他卡效果影响。
function c41554273.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
