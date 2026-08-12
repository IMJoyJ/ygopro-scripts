--ダイナミスト・ラッシュ
-- 效果：
-- 「雾动机龙突进」在1回合只能发动1张。
-- ①：从卡组把1只「雾动机龙」怪兽特殊召唤。这个效果特殊召唤的怪兽不受其他卡的效果影响，结束阶段破坏。
function c41554273.initial_effect(c)
	-- 「雾动机龙突进」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41554273+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41554273.target)
	e1:SetOperation(c41554273.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查以玩家tp来看的卡组中是否存在满足条件的「雾动机龙」怪兽（可特殊召唤）
function c41554273.spfilter(c,e,tp)
	return c:IsSetCard(0xd8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①：从卡组把1只「雾动机龙」怪兽特殊召唤。
function c41554273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp的场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp的卡组中是否存在至少1张满足条件的「雾动机龙」怪兽
		and Duel.IsExistingMatchingCard(c41554273.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时，检查玩家tp的场上是否有空位，若有则提示选择并特殊召唤1只「雾动机龙」怪兽
function c41554273.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp的场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家tp选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家tp的卡组中选择1只满足条件的「雾动机龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c41554273.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到玩家tp的场上
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽不受其他卡的效果影响，结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(tc)
		e1:SetCondition(c41554273.descon)
		e1:SetOperation(c41554273.desop)
		-- 注册一个在结束阶段触发的破坏效果
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(41554273,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 使特殊召唤的怪兽获得效果免疫
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c41554273.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否满足破坏条件
function c41554273.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(41554273)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行破坏操作
function c41554273.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 返回值为true表示该效果不被自身效果影响
function c41554273.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
