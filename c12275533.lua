--機動要犀 トリケライナー
-- 效果：
-- ①：对方对3只以上的怪兽的召唤·反转召唤·特殊召唤成功的回合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受其他卡的效果影响，每次双方的准备阶段守备力下降500。这个效果在对方回合也能发动。
function c12275533.initial_effect(c)
	-- ①：对方对3只以上的怪兽的召唤·反转召唤·特殊召唤成功的回合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12275533,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c12275533.condition)
	e1:SetTarget(c12275533.target)
	e1:SetOperation(c12275533.operation)
	c:RegisterEffect(e1)
	if not c12275533.global_check then
		c12275533.global_check=true
		-- 这个效果特殊召唤的这张卡不受其他卡的效果影响，每次双方的准备阶段守备力下降500。这个效果在对方回合也能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c12275533.checkop)
		-- 注册一个在特殊召唤成功时触发的效果，用于记录召唤次数
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		-- 注册一个在通常召唤成功时触发的效果，用于记录召唤次数
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		-- 注册一个在反转召唤成功时触发的效果，用于记录召唤次数
		Duel.RegisterEffect(ge3,0)
	end
end
-- 检查召唤次数的函数定义
function c12275533.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为召唤玩家注册一个标识效果，表示该玩家已进行过一次召唤/反转召唤/特殊召唤
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),12275533,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 判断是否满足发动条件的函数定义
function c12275533.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方玩家是否已进行过至少3次召唤/反转召唤/特殊召唤
	return Duel.GetFlagEffect(1-tp,12275533)>=3
end
-- 设置效果目标的函数定义
function c12275533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件，包括不在连锁中、场上存在空位、自身可特殊召唤
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果的函数定义
function c12275533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 使特殊召唤的这张卡免疫其他卡的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12275533.efilter)
		c:RegisterEffect(e1)
		-- 在准备阶段时使守备力下降500
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetOperation(c12275533.adjustop)
		c:RegisterEffect(e2)
	end
end
-- 判断效果是否生效的过滤函数定义
function c12275533.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 准备阶段时执行守备力下降效果的函数定义
function c12275533.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置守备力下降500的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
end
