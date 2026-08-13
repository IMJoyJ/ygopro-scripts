--ヨーウィー
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次，这个效果发动的回合，自己只能有1次把怪兽特殊召唤。
-- ①：只让这张卡1只召唤·反转召唤·特殊召唤成功的场合才能发动。下次的对方抽卡阶段跳过。
function c33393090.initial_effect(c)
	-- 开启特殊召唤计数全局标记，使玩家本回合的特殊召唤次数可被统计和限制。
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- 这个卡名的效果在决斗中只能使用1次，这个效果发动的回合，自己只能有1次把怪兽特殊召唤。①：只让这张卡1只召唤·反转召唤·特殊召唤成功的场合才能发动。下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33393090,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33393090+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c33393090.cost)
	e1:SetCondition(c33393090.condition)
	e1:SetTarget(c33393090.target)
	e1:SetOperation(c33393090.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 发动效果的代价处理：根据本回合已进行的特殊召唤次数，若未超过1次则设置本回合特殊召唤次数上限为1；若已有1次则改为禁止特殊召唤，以此保证本回合只能有1次特殊召唤。
function c33393090.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取本回合自己已经进行过的特殊召唤次数。
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if chk==0 then return sp<=1 end
	if sp==0 then
		-- 这个效果发动的回合，自己只能有1次把怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将特殊召唤次数限制效果注册到场上，使本回合自己的特殊召唤次数上限变为1。
		Duel.RegisterEffect(e1,tp)
	else
		-- 这个效果发动的回合，自己只能有1次把怪兽特殊召唤；①：只让这张卡1只召唤·反转召唤·特殊召唤成功的场合才能发动。下次的对方抽卡阶段跳过。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将禁止特殊召唤效果注册到场上，使本回合自己不能再进行特殊召唤。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 发动条件：这次召唤·反转召唤·特殊召唤成功的怪兽只有这张卡自身（即只让这张卡1只召唤·反转召唤·特殊召唤成功）。
function c33393090.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:IsContains(e:GetHandler())
end
-- 发动时点检测：确认对方没有适用跳过抽卡阶段的效果（若已适用则不能发动）。
function c33393090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若对方玩家已适用跳过抽卡阶段的效果，则本效果不能发动。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_DP) end
end
-- 效果处理：给对方玩家设置跳过下次抽卡阶段的效果，并根据当前回合归属决定重置时机。
function c33393090.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断当前是否为发动者的回合，以决定跳过抽卡阶段效果的持续时间（持续到对方回合的结束阶段）。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将跳过对方抽卡阶段的效果注册到场上并生效。
	Duel.RegisterEffect(e1,tp)
end
