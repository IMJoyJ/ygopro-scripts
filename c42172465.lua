--創星改帰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
function c42172465.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42172465+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c42172465.target)
	e1:SetOperation(c42172465.activate)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的「星遗物」怪兽筛选条件：必须是字段为「星遗物」的怪兽，且能够被当前效果特殊召唤。
function c42172465.filter(c,e,tp)
	return c:IsSetCard(0xfe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测：自己主要怪兽区有空位，且手牌·卡组中存在至少1只满足条件的「星遗物」怪兽。
function c42172465.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认我方手牌或卡组中存在至少1只可被该效果特殊召唤的「星遗物」怪兽。
		and Duel.IsExistingMatchingCard(c42172465.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤，目标来源为手牌·卡组，数量为1，持有者为我方。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若无空位则直接终止；否则从手牌·卡组选择1只符合条件的「星遗物」怪兽进行特殊召唤，并对成功召唤的怪兽注册下个结束阶段破坏的标记和延迟破坏效果。
function c42172465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主怪兽区，若已无空位则效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从手牌·卡组选取1只满足筛选条件的「星遗物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c42172465.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 以表侧表示特殊召唤该怪兽；若特殊召唤成功，则继续为它注册下个结束阶段破坏的标记与效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(42172465,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(c42172465.descon)
		e1:SetOperation(c42172465.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录特殊召唤成功时的回合数，用于判断是否已到下个回合的结束阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 将延迟破坏效果注册到当前玩家场上，使它在后续结束阶段能够触发。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成整个特殊召唤过程，统一结算该次特殊召唤的结果。
	Duel.SpecialSummonComplete()
end
-- 破坏效果的触发条件判定：当前回合数不是特殊召唤时的回合（即已经是下个回合），且该怪兽仍带有特殊召唤标记。
function c42172465.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 确认当前回合已不是召唤回合，且该怪兽没有被重置移除标记，仍然需要被破坏。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(42172465)~=0
end
-- 执行破坏动作：取出记录的目标怪兽并予以破坏。
function c42172465.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏该怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
