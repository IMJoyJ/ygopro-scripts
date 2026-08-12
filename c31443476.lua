--クイック・リボルブ
-- 效果：
-- ①：从卡组把1只「弹丸」怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c31443476.initial_effect(c)
	-- 效果发动时，创建一个效果用于特殊召唤怪兽，该效果为发动时点，可以自由连锁，目标为特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31443476.target)
	e1:SetOperation(c31443476.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的「弹丸」怪兽，且可以被特殊召唤
function c31443476.filter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理目标函数，检查是否满足特殊召唤条件，包括场上是否有空位和卡组中是否存在符合条件的怪兽
function c31443476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在至少1只符合条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c31443476.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示本次连锁将处理特殊召唤1只怪兽，目标为玩家卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行特殊召唤操作，包括选择怪兽、特殊召唤并设置其不能攻击和结束阶段破坏效果
function c31443476.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，如果没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家卡组中选择1只符合条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c31443476.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 为特殊召唤的怪兽设置不能攻击的效果，使其在结束阶段被破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(31443476,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 创建一个持续到结束阶段的效果，用于在结束阶段破坏特殊召唤的怪兽
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c31443476.descon)
		e2:SetOperation(c31443476.desop)
		e2:SetCountLimit(1)
		-- 将结束阶段破坏效果注册到场上
		Duel.RegisterEffect(e2,tp)
	end
	-- 完成特殊召唤流程，结束本次特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 判断是否满足结束阶段破坏的条件，即怪兽是否仍处于场上
function c31443476.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(31443476)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行破坏操作，将目标怪兽破坏
function c31443476.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果而破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
