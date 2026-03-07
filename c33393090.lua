--ヨーウィー
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次，这个效果发动的回合，自己只能有1次把怪兽特殊召唤。
-- ①：只让这张卡1只召唤·反转召唤·特殊召唤成功的场合才能发动。下次的对方抽卡阶段跳过。
function c33393090.initial_effect(c)
	-- 启用全局标记，用于统计特殊召唤次数
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- ①：只让这张卡1只召唤·反转召唤·特殊召唤成功的场合才能发动。
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
-- 效果发动时检查玩家的特殊召唤次数，若为0则设置特殊召唤次数限制为1次，否则禁止特殊召唤
function c33393090.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前玩家在本回合已进行的特殊召唤次数
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if chk==0 then return sp<=1 end
	if sp==0 then
		-- 设置特殊召唤次数限制为1次
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到决斗环境
		Duel.RegisterEffect(e1,tp)
	else
		-- 设置不能特殊召唤怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到决斗环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断发动效果的怪兽是否为本次召唤/反转/特殊召唤成功的怪兽
function c33393090.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:IsContains(e:GetHandler())
end
-- 判断是否已跳过对方抽卡阶段
function c33393090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未跳过对方抽卡阶段则可以发动效果
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_DP) end
end
-- 发动效果，跳过对方下个抽卡阶段
function c33393090.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方抽卡阶段跳过
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 若当前回合玩家为效果发动者，则在对方回合结束时重置效果
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将效果注册到决斗环境
	Duel.RegisterEffect(e1,tp)
end
