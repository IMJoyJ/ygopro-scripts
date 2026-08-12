--チューン・ナイト
-- 效果：
-- ①：这张卡特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
function c38783169.initial_effect(c)
	-- 启用额外卡组特殊召唤次数限制的全局计数机制
	aux.EnableExtraDeckSummonCountLimit()
	-- 为卡片实例赋予标准的同盟怪兽机制
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- ①：这张卡特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。这个效果的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38783169,0))  --"这张卡当作调整使用"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c38783169.tntg)
	e1:SetOperation(c38783169.tnop)
	c:RegisterEffect(e1)
end
c38783169.treat_itself_tuner=true
-- 判断该卡是否已具有调整类型，若未具有则允许发动效果
function c38783169.tntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsType(TYPE_TUNER) end
end
-- 将该卡在本回合当作调整使用，并限制玩家在本回合只能从额外卡组特殊召唤一次
function c38783169.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将该卡在本回合当作调整使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38783169.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 持续监控特殊召唤成功事件以更新额外卡组召唤次数限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c38783169.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 注册一个用于限制额外卡组召唤次数的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 定义一个用于限制额外卡组召唤的函数
function c38783169.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 当怪兽从额外卡组特殊召唤且玩家的额外召唤次数已用尽时，禁止该召唤
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 定义一个用于筛选特殊召唤来源为额外卡组的函数
function c38783169.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 当有怪兽从额外卡组特殊召唤时，减少对应玩家的额外召唤次数
function c38783169.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c38783169.cfilter,1,nil,tp) then
		-- 减少当前玩家的额外召唤次数
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(c38783169.cfilter,1,nil,1-tp) then
		-- 减少对手玩家的额外召唤次数
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
