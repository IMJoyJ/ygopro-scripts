--機動要犀 トリケライナー
-- 效果：
-- ①：对方对3只以上的怪兽的召唤·反转召唤·特殊召唤成功的回合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受其他卡的效果影响，每次双方的准备阶段守备力下降500。这个效果在对方回合也能发动。
function c12275533.initial_effect(c)
	-- ①：对方对3只以上的怪兽的召唤·反转召唤·特殊召唤成功的回合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受其他卡的效果影响，每次双方的准备阶段守备力下降500。这个效果在对方回合也能发动。
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
		-- 对方对3只以上的怪兽的召唤·反转召唤·特殊召唤成功的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c12275533.checkop)
		-- 将全局连续效果ge1注册到双方玩家，ge1监听特殊召唤成功事件，用于累计本回合特殊召唤成功的怪兽数。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		-- 将全局连续效果ge2注册到双方玩家，ge2监听通常召唤成功事件，用于累计本回合通常召唤成功的怪兽数。
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		-- 将全局连续效果ge3注册到双方玩家，ge3监听反转召唤成功事件，用于累计本回合反转召唤成功的怪兽数。
		Duel.RegisterEffect(ge3,0)
	end
end
-- checkop是召唤成功事件的操作函数：遍历本次成功召唤的所有怪兽，为每个召唤成功玩家登记一次本回合召唤怪兽的标记。
function c12275533.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为本次召唤怪兽的玩家（tc:GetSummonPlayer()）登记卡号12275533的标识，持续到结束阶段，数量+1，用于统计该玩家本回合召唤·反转召唤·特殊召唤成功的怪兽总次数。
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),12275533,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 特殊召唤效果的发动条件函数：检查对方玩家（1-tp）本回合是否已成功召唤3只以上怪兽，满足才允许发动。
function c12275533.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方玩家本回合怪兽召唤·反转召唤·特殊召唤成功的总次数是否达到3次以上，这是效果发动条件的核心判定。
	return Duel.GetFlagEffect(1-tp,12275533)>=3
end
-- 特殊召唤效果的发动目标选择与合法性检查函数：不取对象，确认手牌中的这张卡可以特殊召唤且自己场上有可用区域。
function c12275533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：此卡不在连锁处理中（STATUS_CHAINING），且自己场上有空的怪兽区域，用于排除无法发动的情形。
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：声明本效果处理时会将这张卡特殊召唤，数量为1，供其他卡片（如星尘龙等）进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理函数：将这张卡从手卡特殊召唤，成功后给它附加上'不受其他卡效果影响'和'每次双方准备阶段守备力下降500'的持续效果。
function c12275533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上；若特殊召唤成功（返回值>0）才继续附加后续效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡不受其他卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12275533.efilter)
		c:RegisterEffect(e1)
		-- 每次双方的准备阶段守备力下降500
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
-- 免疫效果过滤函数：当另一个效果的所有者（te:GetOwner()）与本卡的所有者（e:GetOwner()）不同时，该效果会被免疫，从而只免疫其他卡的效果，不免疫自身效果（如守备力下降效果）。
function c12275533.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 准备阶段降守备力的处理函数：每次双方准备阶段，为这张卡新建一个单次的守备力下降500的效果并注册，实现每回合累积下降500。
function c12275533.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 每次双方的准备阶段守备力下降500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
end
