--創星改帰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
function c42172465.initial_effect(c)
	-- ①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
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
-- 过滤函数，检查以玩家tp来看的自己的手卡和卡组中是否存在满足条件的「星遗物」怪兽（可以被特殊召唤）
function c42172465.filter(c,e,tp)
	return c:IsSetCard(0xfe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查玩家tp的场上是否有空位且手卡或卡组中是否存在满足条件的「星遗物」怪兽
function c42172465.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp的场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp的手卡或卡组中是否存在至少1张满足条件的「星遗物」怪兽
		and Duel.IsExistingMatchingCard(c42172465.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的怪兽数量和来源位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果的发动处理，选择并特殊召唤符合条件的怪兽，并注册其在下个回合结束时被破坏的效果
function c42172465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp的场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从玩家tp的手卡或卡组中选择1张满足条件的「星遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c42172465.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试特殊召唤选中的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(42172465,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- ①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(c42172465.descon)
		e1:SetOperation(c42172465.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录当前回合数用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 将该效果注册给玩家tp
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否到了下个回合的结束阶段且该怪兽仍处于场上
function c42172465.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断当前回合数与记录的回合数不同且该怪兽仍具有标记效果
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(42172465)~=0
end
-- ①：从手卡·卡组把1只「星遗物」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
function c42172465.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该怪兽因效果而破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
